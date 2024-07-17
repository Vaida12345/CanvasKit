//
//  Layer + Delete.metal
//
//
//  Created by Vaida on 7/5/24.
//

#include <metal_stdlib>
using namespace metal;

constant int  width [[function_constant(0)]];
constant bool    _r [[function_constant(1)]];
constant uint8_t  r [[function_constant(2)]];
constant bool    _g [[function_constant(3)]];
constant uint8_t  g [[function_constant(4)]];
constant bool    _b [[function_constant(5)]];
constant uint8_t  b [[function_constant(6)]];
constant bool    _a [[function_constant(7)]];
constant uint8_t  a [[function_constant(8)]];


kernel void layer_fill(device uchar* buffer,
                       device const bool* mask,
                       uint2 index [[thread_position_in_grid]]) {
    int maskIndex = index.y * width + index.x;
    int colorIndex = maskIndex * 4;
    
    bool maskBit = mask[maskIndex];
    
    if (maskBit) {
        if (_r) {
            buffer[colorIndex + 0] = r;
        }
        if (_g) {
            buffer[colorIndex + 1] = g;
        }
        if (_b) {
            buffer[colorIndex + 2] = b;
        }
        if (_a) {
            buffer[colorIndex + 3] = a;
        }
    }
}
