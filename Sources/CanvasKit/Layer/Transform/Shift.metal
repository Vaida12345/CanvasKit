//
//  transform_shift.metal
//  
//
//  Created by Vaida on 7/18/24.
//

#include <metal_stdlib>
using namespace metal;


constant int width    [[function_constant(0)]];
constant int height   [[function_constant(1)]];
constant int offset_x [[function_constant(2)]];
constant int offset_y [[function_constant(3)]];


kernel void transform_shift(device const uchar* buffer,
                            device uchar* result,
                            uint3 index [[thread_position_in_grid]]) {
    int result_x = index.x + offset_x;
    int result_y = index.y + offset_y;
    
    if (result_x < 0 || result_y < 0 || result_x >= width || result_y >= height)
        return;
    
    int source_index = (index.y * width + index.x) * 4 + index.z;
    int dest_index = (result_y * width + result_x) * 4 + index.z;
    
    result[dest_index] = buffer[source_index];
}
