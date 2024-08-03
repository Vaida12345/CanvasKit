//
//  Canvas.metal
//  CanvasKit
//
//  Created by Vaida on 8/3/24.
//

#include <metal_stdlib>
using namespace metal;

struct SingleTexture {
    texture2d<float, access::read> texture;
};

kernel void canvas_make_texture(
    device SingleTexture* textures,
    device int2 *origins,
    constant int& textureCount,
    texture2d<float, access::write> texture,
    uint2 position [[thread_position_in_grid]]
) {
//    texture.write(textures[2].texture.read(position), position);
//    return;
    
    float4 color = float4(0); // last component empty
    float4 alpha = float4(0);
    
    for (int i = 0; i < textureCount; i++) {
        int2 target_position = int2(position) - origins[i];
        
        if (target_position.x < 0 || target_position.y < 0 || target_position.x > int(textures[i].texture.get_width()) || target_position.y > int(textures[i].texture.get_height()))
            continue;
        
        float4 newColor = textures[i].texture.read(uint2(target_position));
        float newAlpha = newColor[3];
        
        for (int c = 0; c < 3; c++) {
            float oldAlpha = alpha[c];
            
            float newComponent = newColor[c];
            float oldComponent = color[c];
            
            float resultAlpha = newAlpha + oldAlpha * (1 - newAlpha);
            if (resultAlpha == 0) continue;
            
            float resultComponent = (newComponent * newAlpha + oldComponent * oldAlpha * (1 - newAlpha)) / resultAlpha;
            
            color[c] = resultComponent;
//            color[c] = newComponent;
            alpha[c] = resultAlpha;
        }
    }
    
    float resultAlpha = max(alpha[0], max(alpha[1], alpha[2]));
    color[3] = resultAlpha;
    
    texture.write(color, position);
}
