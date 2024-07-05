
#include <metal_stdlib>
using namespace metal;


kernel void mask_reverse(device const bool* source,
                         device bool* mask,
                         uint index [[thread_position_in_grid]]) {
    mask[index] = !source[index];
}
