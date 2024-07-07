//
//  Select + Visible.metal
//  
//
//  Created by Vaida on 7/7/24.
//

#include <metal_stdlib>
using namespace metal;


constant int width       [[function_constant(0)]];
constant uchar tolerance [[function_constant(1)]];


kernel void selectByVisible(device const uint8_t* buffer,
                            device bool* mask,
                            uint2 index [[thread_position_in_grid]]) {
    int maskIndex = index.y * width + index.x;
    int colorIndex = maskIndex * 4;
    
    mask[maskIndex] = (buffer[colorIndex + 3] >= 255 - tolerance);
}
