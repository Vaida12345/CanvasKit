//
//  Mask + Render.metal
//  
//
//  Created by Vaida on 7/7/24.
//

#include <metal_stdlib>
using namespace metal;


constant int width [[function_constant(0)]];


kernel void mask_render(device uint8_t* buffer,
                        device bool* mask,
                        uint2 index [[thread_position_in_grid]]) {
    int maskIndex = index.y * width + index.x;
    int colorIndex = maskIndex * 4;
    
    if (mask[maskIndex]) {
        buffer[colorIndex + 0] = 255;
        buffer[colorIndex + 1] = 255;
        buffer[colorIndex + 2] = 255;
        buffer[colorIndex + 3] = 255;
    }
}
