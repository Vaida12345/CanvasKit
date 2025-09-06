//
//  Layer + Select.metal
//  CanvasKit
//
//  Created by Vaida on 8/3/24.
//

#include <metal_stdlib>
#include "../../Structures/Utilities/PartialColor.h"

using namespace metal;


kernel void layer_selectByVisible(texture2d<half, access::read>  layer,
                                  texture2d<half, access::write> mask,
                                  uint2 position [[thread_position_in_grid]]) {
    half4 color = layer.read(position);
    mask.write(color.a, position);
}

kernel void layer_selectByColor(texture2d<half, access::sample> layer,
                                texture2d<half, access::write> mask,
                                constant float& tolerance,
                                constant PartialColor& target,
                                constant ushort& N,
                                sampler smp,
                                uint2 position [[thread_position_in_grid]]) {
    float2 pix = float2(position);
    float2 size = float2(layer.get_width(), layer.get_height());
    float invN  = 1.0 / float(N);
    float sigma = 0.5;
    float twoSigma2 = 2.0 * sigma * sigma;
    
    float sumW = 0.0;
    float sumH = 0.0;
    
    for (ushort i = 0; i < N; ++i) {
        for (ushort j = 0; j < N; ++j) {
            // offset ∈ [–0.5…+0.5] pixels
            float2 offs = float2(
                                 (float(i) + 0.5) * invN - 0.5,
                                 (float(j) + 0.5) * invN - 0.5
                                 );
            
            // compute weight from Gaussian(0, σ²):
            float r2 = dot(offs, offs);
            float w  = exp(-r2 / twoSigma2);
            
            // sample at subpixel:
            float2 uv = (pix + offs) / size;
            half4 c   = layer.sample(smp, uv);
            
            // color‐distance test
            bool pass = true;
            for (int k = 0; k < 4; ++k) {
                if (!target.presence[k]) continue;
                if (fabs(float(c[k]) - target.components[k]) > tolerance) {
                    pass = false;
                    break;
                }
            }
            
            sumW += w;
            if (pass) sumH += w;
        }
    }
    
    // normalize
    float coverage = sumH / sumW;
    mask.write(half(coverage), position);
}

kernel void layer_selectByPoint(texture2d<half, access::read>  layer,
                                texture2d<half, access::write> mask,
                                constant float& tolerance,
                                constant uint2& point,
                                uint2 position [[thread_position_in_grid]]) {
    half4 color = layer.read(position);
    half4 target = layer.read(point);
    half shouldSelect = 1;
    
    for (int c = 0; c < 4; c++) {
        if (!shouldSelect) break;
        
        if (abs(color[c] - target[c]) > float(tolerance)) {
            shouldSelect = 0;
        }
    }
    
    if (shouldSelect) {
        mask.write(1, position);
    }
}
