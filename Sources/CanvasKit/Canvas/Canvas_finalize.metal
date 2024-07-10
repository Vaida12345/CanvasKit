//
//  Canvas_finalize.metal
//
//
//  Created by Vaida on 7/10/24.
//

#include <metal_stdlib>
using namespace metal;

constant int width [[function_constant(0)]];

kernel void canvas_finalize(device const uchar* buffer,
                            device uchar* result,
                            uint2 index [[thread_position_in_grid]]) {
    int index_i = 6 * ((index.y * width) + index.x);
    int index_o = 4 * ((index.y * width) + index.x);
    int alpha = max(buffer[index_i + 1], max(buffer[index_i + 3], buffer[index_i + 5]));
    
    result[index_o + 0] = buffer[index_i + 0];
    result[index_o + 1] = buffer[index_i + 2];
    result[index_o + 2] = buffer[index_i + 4];
    result[index_o + 3] = alpha;
}
