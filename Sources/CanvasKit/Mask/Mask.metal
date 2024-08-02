
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
    int2 rectMin = rect.origin;
    int2 rectMax = rect.origin + rect.size;
    
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


kernel void mask_check_full_zeros(texture2d<uint, access::read> texture [[texture(0)]],
                                  device bool* result [[buffer(0)]],
                                  uint2 position [[thread_position_in_grid]]) {
    // Read the pixel value at the current position
    uint pixelValue = texture.read(position).r;
    
    // Check if the pixel is non-zero
    if (pixelValue != 0) {
        // Atomic update to indicate that a non-zero value is found
        *result = false;
    }
}


kernel void mask_check_zeros_by_rows_columns(texture2d<uint, access::read> texture [[texture(0)]],
                                     device bool* rows [[buffer(0)]],
                                     device bool* columns [[buffer(1)]],
                                     uint2 position [[thread_position_in_grid]]) {
    // Read the pixel value at the current position
    uint pixelValue = texture.read(position).r;
    
    // Check if the pixel is non-zero
    if (pixelValue != 0) {
        rows[position.y] = true;
        columns[position.x] = true;
    }
}


kernel void mask_duplicate_inverse(texture2d<uint, access::read>  input  [[texture(0)]],
                                   texture2d<uint, access::write> output [[texture(1)]],
                                   uint2 position [[thread_position_in_grid]]) {
    output.write(255 - input.read(position).r, position);
}


kernel void mask_expand(texture2d<uint, access::read>  input  [[texture(0)]],
                        texture2d<uint, access::write> output [[texture(1)]],
                        constant DiscreteRect& rect,
                        uint2 position [[thread_position_in_grid]]) {
    int2 dest = int2(position) - rect.origin;
    
    if (dest.x < 0 || dest.y < 0 || dest.x >= rect.size.x || dest.y >= rect.size.y)
        return;
    
    uint pixelValue = input.read(position).r;
    output.write(pixelValue, uint2(dest));
}
