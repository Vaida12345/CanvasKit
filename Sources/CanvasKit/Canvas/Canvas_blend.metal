//
//  Canvas_blend.metal
//  
//
//  Created by Vaida on 7/10/24.
//


#include <metal_stdlib>
using namespace metal;

constant int width     [[function_constant(0)]];
constant int nl_width  [[function_constant(1)]];
constant int nl_height [[function_constant(2)]];
constant int nl_x      [[function_constant(3)]];
constant int nl_y      [[function_constant(4)]];


kernel void canvas_blend(device uchar* buffer,
                         device const uchar* newLayer,
                         uint3 index [[thread_position_in_grid]]) { // x, y, color
    if (int(index.y) < nl_y || int(index.x) < nl_x || int(index.y) >= nl_y + nl_height || int(index.x) >= nl_x + nl_width)
        return;
    
    int colorIndex = (((index.y - nl_y) * nl_width) + (index.x - nl_x)) * 4;
//    int colorIndex = (((index.y) * width) + (index.x)) * 4;
    
    float newAlpha = float(newLayer[colorIndex + 3]) / 255;
    float oldAlpha = float(buffer[((index.y * width) + index.x) * 6 + index.z * 2 + 1]) / 255;
    
    float newComponent = float(newLayer[colorIndex + index.z]) / 255;
    float oldComponent = float(buffer[((index.y * width) + index.x) * 6 + index.z * 2]) / 255;
    
    float resultAlpha = newAlpha + oldAlpha * (1 - newAlpha);
    float resultComponent = (newComponent * newAlpha + oldComponent * oldAlpha * (1 - newAlpha)) / resultAlpha;
    
    buffer[((index.y * width) + index.x) * 6 + index.z * 2] = uint8_t(resultComponent * 255);
    buffer[((index.y * width) + index.x) * 6 + index.z * 2 + 1] = uint8_t(resultAlpha * 255);
}
