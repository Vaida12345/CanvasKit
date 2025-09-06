
#include <metal_stdlib>
#include "../Structures/Util.h"
#include "../Structures/Utilities/DiscreteRect.h"

using namespace metal;

kernel void mask_fill_with(texture2d<half, access::write> texture,
                           constant char& fill,
                           uint2 position [[thread_position_in_grid]]) {
    texture.write(half(fill) / 255, position);
}


kernel void mask_fill_with_selection(texture2d<half, access::write> texture,
                                     constant DiscreteRect& rect,
                                     uint2 _position [[thread_position_in_grid]]) {
    // Calculate the bounds of the rectangle
    int2 rectMin = rect.origin;
    int2 rectMax = rect.origin + rect.size;
    int2 position = int2(_position);
    
    // Check if the current position is within the rectangle
    if (position.x >= rectMin.x && position.x < rectMax.x &&
        position.y >= rectMin.y && position.y < rectMax.y) {
        // Inside the rectangle: set the pixel value to 255
        texture.write(1, _position);
    } else {
        // Outside the rectangle: set the pixel value to 0
        texture.write(0, _position);
    }
}


kernel void mask_check_full_zeros(texture2d<half, access::read> texture [[texture(0)]],
                                  device bool* result [[buffer(0)]],
                                  uint2 position [[thread_position_in_grid]]) {
    // Read the pixel value at the current position
    half pixelValue = texture.read(position).r;
    
    // Check if the pixel is non-zero
    if (pixelValue != 0) {
        // only write is to set it to false, hence no racing
        *result = false;
    }
}


kernel void mask_check_zeros_by_rows_columns(texture2d<half, access::read> texture [[texture(0)]],
                                     device bool* rows [[buffer(0)]],
                                     device bool* columns [[buffer(1)]],
                                     uint2 position [[thread_position_in_grid]]) {
    // Read the pixel value at the current position
    half pixelValue = texture.read(position).r;
    
    // Check if the pixel is non-zero
    if (pixelValue != 0) {
        rows[position.y] = true;
        columns[position.x] = true;
    }
}


kernel void mask_duplicate_inverse(texture2d<half, access::read>  input  [[texture(0)]],
                                   texture2d<half, access::write> output [[texture(1)]],
                                   uint2 position [[thread_position_in_grid]]) {
    output.write(1 - input.read(position).r, position);
}


kernel void mask_expand(texture2d<half, access::sample>  input  [[texture(0)]],
                        texture2d<half, access::write>   output [[texture(1)]],
                        constant float2& origin,
                        uint2 dest [[thread_position_in_grid]]) {
    float2 source = float2(dest) + origin;
    
    if (source.x < 0 || source.y < 0 || source.x > float(input.get_width()) || source.y > float(input.get_height())) return;
    
    half pixelValue = texture_sample_at(input, source).r;
    output.write(pixelValue, dest);
}


kernel void mask_quantize(texture2d<half, access::read>  input  [[texture(0)]],
                          texture2d<half, access::write> output [[texture(1)]],
                          constant float& tolerance,
                          uint2 position [[thread_position_in_grid]]) {
    half value = input.read(position).r;
    
    if (value > half(tolerance)) {
        output.write(1, position);
    }
}
