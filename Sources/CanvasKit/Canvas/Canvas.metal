//
//  Canvas.metal
//  CanvasKit
//
//  Created by Vaida on 8/3/24.
//

#include <metal_stdlib>
#include "../Structures/Util.h"

using namespace metal;

struct SingleTexture {
    texture2d<half, access::sample> texture;
};

kernel void canvas_make_texture(
    device const SingleTexture*  textures      [[ buffer(0) ]],
    device const float2*         origins       [[ buffer(1) ]],
    constant uint&               textureCount  [[ buffer(2) ]],
    texture2d<half, access::write> output      [[ texture(0) ]],
    uint2                        position      [[ thread_position_in_grid ]]
) {
    // Accumulator in premultiplied space:
    half3 accumColor = half3(0.0);
    half  accumAlpha = 0.0;
    
    // Loop over each layer
    for (uint i = 0; i < textureCount; i++) {
        // Compute the corresponding texel in layer i
        float2 localPos = float2(position) - origins[i];
        
        // Cull out-of-bounds
        if (localPos.x < 0.0 ||
            localPos.y < 0.0 ||
            localPos.x >= float(textures[i].texture.get_width())  ||
            localPos.y >= float(textures[i].texture.get_height()))
        {
            continue;
        }
        
        // Read the layer’s RGBA
        half4 src = texture_sample_at(textures[i].texture, localPos);
        
        half3 srcRGB       = src.rgb;
        half  srcAlpha     = src.a;
        
        // Convert to premultiplied
        half3 srcRGB_pm    = srcRGB * srcAlpha;
        
        // Standard Porter-Duff "over" composite:
        // out_pm.rgb   = src_pm + dst_pm * (1 - src_a)
        // out_alpha    = src_a + dst_a * (1 - src_a)
        accumColor       = srcRGB_pm + accumColor * (1.0 - srcAlpha);
        accumAlpha       = srcAlpha + accumAlpha * (1.0 - srcAlpha);
    }
    
    // Un-premultiply (so we end up with normal RGBA again)
    half3 finalRGB = (accumAlpha > 0.0)
    ? accumColor / accumAlpha
    : half3(0.0);
    
    half4 outColor = half4(finalRGB, accumAlpha);
    
    output.write(outColor, position);
}
