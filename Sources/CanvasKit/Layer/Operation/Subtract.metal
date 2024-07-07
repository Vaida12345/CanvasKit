//
//  Subtract.metal
//  
//
//  Created by Vaida on 6/28/24.
//

#include <metal_stdlib>
using namespace metal;

constant int width [[function_constant(0)]];


kernel void subtract(device uchar* input,
                     device const uchar* _rhs,
                     uint3 index [[thread_position_in_grid]]) { // x, y, color
    int colorIndex = 4 * (width * index.y + index.x) + index.z;
    
    uchar lhs = input[colorIndex];
    uchar rhs =  _rhs[colorIndex];
    
    if (lhs < rhs) {
        input[colorIndex]= rhs - lhs;
    } else {
        input[colorIndex] = lhs - rhs;
    }
}
