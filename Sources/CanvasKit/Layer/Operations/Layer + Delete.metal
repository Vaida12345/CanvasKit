//
//  Layer + Delete.metal
//
//
//  Created by Vaida on 7/5/24.
//


#include <metal_stdlib>
using namespace metal;

constant int width [[function_constant(0)]];


kernel void layer_delete(device uint8_t* buffer,
                         device const bool* mask,
                         uint2 index [[thread_position_in_grid]]) {
    int maskIndex = index.y * width + index.x;
    int colorIndex = maskIndex * 4;
    
    int maskBit = mask[maskIndex];
    
    if (maskBit) {
        buffer[colorIndex + 3] = 0; // set alpha to 0.
    }
}
