
#include <metal_stdlib>
using namespace metal;

kernel void mask_fill_with(texture2d<uint, access::write> texture,
                           constant uint& fill,
                           uint2 position [[thread_position_in_grid]]) {
    texture.write(fill, position);
}

