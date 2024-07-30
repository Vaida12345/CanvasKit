
#include <metal_stdlib>
#include "../Structures/Utilities/DiscreteRect.h"
using namespace metal;

kernel void mask_fill_with(texture2d<uint, access::write> texture,
                           constant uint& fill,
                           uint2 position [[thread_position_in_grid]]) {
    texture.write(fill, position);
}


kernel void mask_fill_with_selection(texture2d<uint, access::write> texture,
                                     constant DiscreteRect& rect,
                                     uint2 position [[thread_position_in_grid]]) {
    // Calculate the bounds of the rectangle
    uint2 rectMin = rect.origin;
    uint2 rectMax = rect.origin + rect.size;
    
    // Check if the current position is within the rectangle
    if (position.x >= rectMin.x && position.x < rectMax.x &&
        position.y >= rectMin.y && position.y < rectMax.y) {
        // Inside the rectangle: set the pixel value to 255
        texture.write(255, position);
    } else {
        // Outside the rectangle: set the pixel value to 0
        texture.write(0, position);
    }
}
