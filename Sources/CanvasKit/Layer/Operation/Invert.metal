
#include <metal_stdlib>
using namespace metal;

constant int width  [[function_constant(0)]];


kernel void invert(device uchar* input,
                   uint3 index [[thread_position_in_grid]]) { // x, y, color
    int z = index.z;
    uchar reference = 255;
    if (z != 3) {
        int colorIndex = 4 * (width * index.y + index.x) + index.z;
        uchar val = input[colorIndex];
        input[colorIndex] = reference - val;
    }
}
