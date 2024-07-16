//
//  Layer + Expand.metal
//
//
//  Created by Vaida on 7/5/24.
//

#include <metal_stdlib>
using namespace metal;

constant int width        [[function_constant(0)]];
constant int height       [[function_constant(1)]];
constant int frame_x      [[function_constant(2)]];
constant int frame_y      [[function_constant(3)]];
constant int frame_width  [[function_constant(4)]];
constant int frame_height [[function_constant(5)]];


kernel void layer_expand(device const uint8_t* source,
                         device uint8_t* buffer,
                         uint3 index [[thread_position_in_grid]]) {
    int source_x = index.x + frame_x;
    int source_y = index.y + frame_y;
    
    if (source_x < 0 || source_y < 0 || source_x > width || source_y > height)
        return;
    
    int source_index = (source_y * width + source_x) * 4 + index.z;
    
    int _index = (index.y * frame_width + index.x) * 4 + index.z;
    
    buffer[_index] = source[source_index];
}
