//
//  Mask + Expand.metal
//
//
//  Created by Vaida on 7/17/24.
//

#include <metal_stdlib>
using namespace metal;

constant int width        [[function_constant(0)]];
constant int height       [[function_constant(1)]];
constant int frame_x      [[function_constant(2)]];
constant int frame_y      [[function_constant(3)]];
constant int frame_width  [[function_constant(4)]];
constant int frame_height [[function_constant(5)]];


kernel void mask_expand(device const uint8_t* source,
                        device uint8_t* buffer,
                        uint2 index [[thread_position_in_grid]]) {
    int dest_x = index.x - frame_x;
    int dest_y = index.y - frame_y;
    
    if (dest_x < 0 || dest_y < 0 || dest_x >= frame_width || dest_y >= frame_height)
        return;
    
    int source_index = index.y * width + index.x;
    
    int dest_index = dest_y * frame_width + dest_x;
    
    buffer[dest_index] = source[source_index];
}
