//
//  Layer + Select.metal
//  CanvasKit
//
//  Created by Vaida on 8/3/24.
//

#include <metal_stdlib>
#include "../../Structures/Utilities/PartialColor.h"

using namespace metal;


kernel void layer_selectByVisible(texture2d<float, access::read>  layer,
                                  texture2d<float, access::write> mask,
                                  constant float& tolerance,
                                  uint2 position [[thread_position_in_grid]]) {
    float4 color = layer.read(position);
    if (color.a >= 1 - tolerance) {
        mask.write(1, position);
    }
}

kernel void layer_selectByColor(texture2d<float, access::read>  layer,
                                texture2d<float, access::write> mask,
                                constant float& tolerance,
                                constant PartialColor& target,
                                uint2 position [[thread_position_in_grid]]) {
    float4 color = layer.read(position);
    float shouldSelect = 1;
    
    for (int c = 0; c < 4; c++) {
        if (!target.presence[c]) continue;
        if (!shouldSelect) break;
        
        if (abs(color[c] - target.components[c]) > tolerance) {
            shouldSelect = 0;
        }
    }
    
    if (shouldSelect) {
        mask.write(1, position);
    }
}
