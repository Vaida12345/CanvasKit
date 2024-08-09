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
    device SingleTexture* textures,
    device float2 *origins,
    constant int& textureCount,
    texture2d<half, access::write> output,
    uint2 position [[thread_position_in_grid]]
) {
//    texture.write(textures[2].texture.read(position), position);
//    return;
    
    half4 color = half4(0); // last component empty
    half4 alpha = half4(0);
    
    for (int i = 0; i < textureCount; i++) {
        float2 target_position = float2(position) - origins[i];
        
        if (target_position.x < 0 || target_position.y < 0 || target_position.x > float(textures[i].texture.get_width()) || target_position.y > float(textures[i].texture.get_height()))
            continue;
        
        half4 newColor = texture_sample_at(textures[i].texture, target_position);
        half newAlpha = newColor[3];
        
        for (int c = 0; c < 3; c++) {
            half oldAlpha = alpha[c];
            
            half newComponent = newColor[c];
            half oldComponent = color[c];
            
            half resultAlpha = newAlpha + oldAlpha * (1 - newAlpha);
            if (resultAlpha == 0) continue;
            
            half resultComponent = (newComponent * newAlpha + oldComponent * oldAlpha * (1 - newAlpha)) / resultAlpha;
            
            color[c] = resultComponent;
            alpha[c] = resultAlpha;
        }
    }
    
    half resultAlpha = max(alpha[0], max(alpha[1], alpha[2]));
    color[3] = resultAlpha;
    
    output.write(color, position);
}
