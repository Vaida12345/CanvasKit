//
//  Select + Color.metal
//  
//
//  Created by Vaida on 7/5/24.
//

#include <metal_stdlib>
using namespace metal;


constant int width         [[function_constant(0)]];
constant uint8_t color_r   [[function_constant(1)]];
constant uint8_t color_g   [[function_constant(2)]];
constant uint8_t color_b   [[function_constant(3)]];
constant uint8_t tolerance [[function_constant(4)]];

int isSimilar(uint8_t lhs, uint8_t rhs, uint8_t tolerance);


kernel void selectByColor(device const uint8_t* buffer,
                          device bool* mask,
                          uint2 index [[thread_position_in_grid]]) {
    int maskIndex = index.y * width + index.x;
    int colorIndex = maskIndex * 4;
    
    uint8_t r = buffer[colorIndex + 0];
    uint8_t g = buffer[colorIndex + 1];
    uint8_t b = buffer[colorIndex + 2];
    
    mask[maskIndex] = isSimilar(color_r, r, tolerance) && isSimilar(color_g, g, tolerance) && isSimilar(color_b, b, tolerance);
}


int isSimilar(uint8_t lhs, uint8_t rhs, uint8_t tolerance) {
    if (lhs < rhs) {
        return (rhs - lhs) <= tolerance;
    } else {
        return (lhs - rhs) <= tolerance;
    }
}
