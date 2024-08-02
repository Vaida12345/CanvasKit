
#include <metal_stdlib>
#include "../Structures/Utilities/PartialColor.h"
#include "../Structures/Utilities/DiscreteRect.h"

using namespace metal;


kernel void layer_duplicate(texture2d<float, access::read>  input,
                            texture2d<float, access::write> output,
                            uint2 position [[thread_position_in_grid]]) {
    
    output.write(input.read(position), position);
}

kernel void layer_duplicate_with_mask(texture2d<float, access::read>  input,
                                      texture2d<float, access::write> output,
                                      texture2d<float, access::read>  mask,
                                      uint2 position [[thread_position_in_grid]]) {
    float maskValue = mask.read(position)[0];
    if (!maskValue) return;
    
    output.write(input.read(position), position);
}

kernel void layer_fill(texture2d<float, access::read_write> layer,
                       texture2d<float, access::read> mask,
                       constant PartialColor& color,
                       uint2 position [[thread_position_in_grid]]) {
    float maskValue = mask.read(position)[0];
    if (!maskValue) return;
    
    float4 target = layer.read(position);
    
    for (int i = 0; i < 4; i++) {
        if (color.presence[i])
            target[i] = color.components[i];
    }
    
    layer.write(target, position);
}

kernel void layer_expand(texture2d<float, access::read>  input  [[texture(0)]],
                         texture2d<float, access::write> output [[texture(1)]],
                         constant DiscreteRect& rect,
                         uint2 position [[thread_position_in_grid]]) {
    int2 dest = int2(position) - rect.origin;
    
    if (dest.x < 0 || dest.y < 0 || dest.x >= rect.size.x || dest.y >= rect.size.y)
        return;
    
    float4 pixelValue = input.read(position);
    output.write(pixelValue, uint2(dest));
}

kernel void layer_invert(texture2d<float, access::read_write> layer,
                         uint2 position [[thread_position_in_grid]]) {
    float reference = 1;
    
    float4 target = layer.read(position);
    
    for (int i = 0; i < 3; i++) {
        target[i] = reference - target[i];
    }
    
    layer.write(target, position);
}
