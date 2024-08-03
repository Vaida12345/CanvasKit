
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


// Define a utility function to calculate the Lanczos kernel weight.
float lanczosWeight(float x, float lanczos_kernel) {
    if (x == 0.0) return 1.0;
    if (abs(x) >= lanczos_kernel) return 0.0;
    float pi_x = 3.14159265358979323846 * x;
    return lanczos_kernel * sin(pi_x) * sin(pi_x / float(lanczos_kernel)) / (pi_x * pi_x);
}


kernel void lanczosResample(texture2d<float, access::read>  input,
                            texture2d<float, access::write> output,
                            uint2 output_position [[thread_position_in_grid]]) {
    float lanczos_kernel = 2; // 2 or 3
    
    int2 input_size  = int2(input.get_width(),  input.get_height());
    int2 output_size = int2(output.get_width(), output.get_height());
    
    float2 input_position_float = float2(output_position) * float2(input_size) / float2(output_size);
    int2 input_position = int2(input_position_float);
    float4 totalColor = float4(0);
    float totalWeight = 0;
    
    for(int j = -lanczos_kernel; j < lanczos_kernel; j++) {
        for(int i = -lanczos_kernel; i < lanczos_kernel; i++) {
            float weight = lanczosWeight(float(i) - (input_position_float.x - float(input_position.x)), lanczos_kernel)
                         * lanczosWeight(float(j) - (input_position_float.y - float(input_position.y)), lanczos_kernel);
            int2 delta = int2(i, j);
            int2 pixel_position = min(max(input_position + delta, int2(0)), input_size - 1);
            
            float4 color = input.read(uint2(pixel_position));
            totalColor += color * weight;
            
            totalWeight += weight;
        }
    }
    
    float4 output_color = totalColor / totalWeight;
    output.write(output_color, output_position);
}
