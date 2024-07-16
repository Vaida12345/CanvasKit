
#include <metal_stdlib>
using namespace metal;

constant bool repeatedValue [[function_constant(0)]];


kernel void mask_repeat(device bool* mask,
                        uint index [[thread_position_in_grid]]) {
    mask[index] = repeatedValue;
}
