
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

kernel void layer_fill_with_mask(texture2d<float, access::read_write> layer,
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

kernel void layer_fill(texture2d<float, access::read_write> layer,
                       constant PartialColor& color,
                       uint2 position [[thread_position_in_grid]]) {
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

kernel void layer_subtract(texture2d<float, access::read_write> layer,
                           texture2d<float, access::read>       other,
                           uint2 position [[thread_position_in_grid]]) {
    float4 target = layer.read(position);
    float4 value  = other.read(position);
    
    if (value[3] != 0 && target[3] != 0) {
        for (int i = 0; i < 3; i++) {
            target[i] -= value[i];
        }
    }
    
    layer.write(target, position);
}

kernel void layer_convolution(texture2d<float, access::read> input,
                              texture2d<float, access::write> output,
                              device const float* _kernel,
                              constant int2& size,
                              uint2 position [[thread_position_in_grid]]) {
    float4 sum = float4(0);
    
    int2 paddings = size / 2;
    
    int width = input.get_width();
    int height = input.get_height();
    int2 texture_size = int2(width, height);
    
    for (int i = 0; i < size[0]; i++) {
        for (int j = 0; j < size[1]; j++) {
            int2 delta = int2(i, j) - paddings;
            
            int2 _position = int2(position) + delta;
            
            for (int k = 0; k < 2; k++) {
                _position[k] = _position[k] >= 0 ? _position[k] : abs(_position[k]) - 1; // reflective padding
                _position[k] = _position[k] < texture_size[k] ? _position[k] : texture_size[k]  - 1;
            }
            
            float4 color = input.read(uint2(_position));
            sum += color * _kernel[j * size[0] + i];
        }
    }
    
    output.write(sum, position);
}
