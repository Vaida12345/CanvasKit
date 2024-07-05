//
//  Layer + Crop.metal
//  
//
//  Created by Vaida on 7/5/24.
//

#include <metal_stdlib>
using namespace metal;

constant int  width        [[function_constant(0)]];
constant uint frame_x      [[function_constant(1)]];
constant uint frame_y      [[function_constant(2)]];
constant uint frame_width  [[function_constant(3)]];
constant uint frame_height [[function_constant(4)]];


kernel void layer_crop(device const uint8_t* source,
                       device uint8_t* buffer,
                       uint3 index [[thread_position_in_grid]]) {
    int source_x = index.x + frame_x;
    int source_y = index.y + frame_y;
    int source_index = (source_y * width + source_x) * 4 + index.z;
    
    int _index = (index.y * frame_width + index.x) * 4 + index.z;
    
    buffer[_index] = source[source_index];
}
