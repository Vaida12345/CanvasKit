
#include <metal_stdlib>
#include "../Structures/Utilities/PartialColor.h"

using namespace metal;


kernel void layer_duplicate(texture2d<uint, access::read>  input,
                            texture2d<uint, access::write> output,
                            uint2 position [[thread_position_in_grid]]) {
    
    output.write(input.read(position), position);
}

kernel void layer_duplicate_with_mask(texture2d<uint, access::read>  input,
                                      texture2d<uint, access::write> output,
                                      texture2d<uint, access::read>  mask,
                                      uint2 position [[thread_position_in_grid]]) {
    uint maskValue = mask.read(position)[0];
    if (!maskValue) return;
    
    output.write(input.read(position), position);
}

kernel void layer_fill(texture2d<uint, access::read_write> layer,
                       texture2d<uint, access::read> mask,
                       constant PartialColor& color,
                       uint2 position [[thread_position_in_grid]]) {
    uint maskValue = mask.read(position)[0];
    if (!maskValue) return;
    
    uint4 target = layer.read(position);
    
    for (int i = 0; i < 4; i++) {
        if (color.presence[i])
            target[i] = color.components[i];
    }
    
    layer.write(target, position);
}
