//
//  Mask + Select.metal
//  
//
//  Created by Vaida on 7/10/24.
//

#include <metal_stdlib>
using namespace metal;


constant int width   [[function_constant(0)]];
constant uint frame_x [[function_constant(1)]];
constant uint frame_y [[function_constant(2)]];
constant uint frame_w [[function_constant(3)]];
constant uint frame_h [[function_constant(4)]];


kernel void mask_select(device bool* mask,
                        uint2 index [[thread_position_in_grid]]) {
    
    int maskIndex = index.y * width + index.x;
    mask[maskIndex] = !(index.x < frame_x || index.x > frame_x + frame_w || index.y < frame_y || index.y > frame_y + frame_h);
}
