
#include <metal_stdlib>
#include "../Structures/Util.h"
#include "../Structures/Utilities/PartialColor.h"
#include "../Structures/Utilities/DiscreteRect.h"
#include "../Structures/Utilities/LinearGradient.h"

using namespace metal;


kernel void layer_duplicate(texture2d<half, access::read>  input,
                            texture2d<half, access::write> output,
                            uint2 position [[thread_position_in_grid]]) {
    
    output.write(input.read(position), position);
}

kernel void layer_duplicate_with_mask(texture2d<half, access::read>  input,
                                      texture2d<half, access::write> output,
                                      texture2d<half, access::read>  mask,
                                      uint2 position [[thread_position_in_grid]]) {
    half maskValue = mask.read(position)[0];
    if (!maskValue) return;
    
    output.write(input.read(position) * maskValue, position);
}

kernel void layer_fill_with_mask(texture2d<half, access::read_write> layer,
                                 texture2d<half, access::read> mask,
                                 constant PartialColor& color,
                                 uint2 position [[thread_position_in_grid]]) {
    half maskValue = mask.read(position)[0];
    if (!maskValue) return;
    
    half4 target = layer.read(position);
    
    for (int i = 0; i < 4; i++) {
        if (color.presence[i])
            target[i] = half(color.components[i]);
    }
    target[3] *= maskValue;
    
    layer.write(target, position);
}

kernel void layer_fill_linear_gradient_with_mask(texture2d<half, access::read_write> layer,
                                                 texture2d<half, access::read> mask,
                                                 constant LinearGradient& gradient,
                                                 constant DiscreteRect& boundary,
                                                 uint2 position [[thread_position_in_grid]]) {
    half maskValue = mask.read(position)[0];
    if (!maskValue) return;
    
    half4 target = layer.read(position);
    
    int d = int(gradient.direction);
    
    for (int i = 0; i < 4; i++) {
        if (!gradient.startColor.presence[i]) continue;
        if (int(position[d]) < boundary.origin[d]) continue;
        if (int(position[d]) > boundary.origin[d] + boundary.size[d]) continue;
        
        float progress = float(position[d] - boundary.origin[d]) / float(boundary.size[d]);
        target[i] = half(gradient.startColor.components[i] * (1 - progress) + gradient.endColor.components[i] * progress);
    }
    
    layer.write(target, position);
}

kernel void layer_fill_with_rect(texture2d<half, access::read_write> layer,
                                 constant uint2& origin,
                                 constant PartialColor& color,
                                 uint2 position [[thread_position_in_grid]]) {
    uint2 target_position = position + origin;
    
    half4 target = half4(0);
    
    for (int i = 0; i < 4; i++) {
        if (color.presence[i])
            target[i] = half(color.components[i]);
    }
    
    layer.write(target, target_position);
}

kernel void layer_fill(texture2d<half, access::read_write> layer,
                       constant PartialColor& color,
                       uint2 position [[thread_position_in_grid]]) {
    half4 target = layer.read(position);
    
    for (int i = 0; i < 4; i++) {
        if (color.presence[i])
            target[i] = half(color.components[i]);
    }
    
    layer.write(target, position);
}

kernel void layer_fill_linear_gradient(texture2d<half, access::read_write> layer,
                                       constant LinearGradient& gradient,
                                       uint2 position [[thread_position_in_grid]]) {
    half4 target = layer.read(position);
    float2 size = float2(layer.get_width(), layer.get_height());
    
    int d = int(gradient.direction);
    for (int i = 0; i < 4; i++) {
        if (!gradient.startColor.presence[i]) continue;
        
        float progress = float(position[d]) / size[d];
        target[i] = half(gradient.startColor.components[i] * (1 - progress) + gradient.endColor.components[i] * progress);
    }
    
    layer.write(target, position);
}

kernel void layer_expand(texture2d<half, access::sample>  input  [[texture(0)]],
                         texture2d<half, access::write>   output [[texture(1)]],
                         constant float2& origin,
                         uint2 dest [[thread_position_in_grid]]) {
    float2 source = float2(dest) + origin;
    
    if (source.x < 0 || source.y < 0 || source.x > float(input.get_width()) || source.y > float(input.get_height())) return;
    
    
    half4 pixelValue = texture_sample_at(input, source);
    output.write(pixelValue, dest);
}

kernel void layer_invert(texture2d<half, access::read_write> layer,
                         uint2 position [[thread_position_in_grid]]) {
    half reference = 1;
    
    half4 target = layer.read(position);
    
    for (int i = 0; i < 3; i++) {
        target[i] = reference - target[i];
    }
    
    layer.write(target, position);
}

kernel void layer_subtract(texture2d<half, access::read_write> layer,
                           texture2d<half, access::read>       other,
                           uint2 position [[thread_position_in_grid]]) {
    half4 target = layer.read(position);
    half4 value  = other.read(position);
    
    if (value[3] != 0 && target[3] != 0) {
        for (int i = 0; i < 3; i++) {
            target[i] -= value[i];
        }
    }
    
    layer.write(target, position);
}

kernel void layer_convolution(texture2d<half, access::read> input,
                              texture2d<half, access::write> output,
                              device const float* _kernel,
                              constant int2& size,
                              constant uchar& layerIndexes,
                              uint2 position [[thread_position_in_grid]]) {
    half4 sum = half4(0);
    
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
            
            half4 color = input.read(uint2(_position));
            sum += color * half(_kernel[j * size[0] + i]);
        }
    }
    
    half4 originalColor = input.read(position);
    for (int z = 0; z < 4; z ++) {
        if ((layerIndexes & 1 << z) == 0)
            sum[z] = originalColor[z];
    }
    
    output.write(sum, position);
}


// Define a utility function to calculate the Lanczos kernel weight.
float lanczosWeight(float x, float lanczos_kernel) {
    if (x == 0.0) return 1.0;
    float pi_x = 3.14159265358979323846 * x;
    return lanczos_kernel * sin(pi_x) * sin(pi_x / lanczos_kernel) / (pi_x * pi_x);
}


kernel void lanczosResample(texture2d<half, access::sample> input,
                            texture2d<half, access::write>  output,
                            uint2 output_position [[thread_position_in_grid]]) {
    int lanczos_kernel = 2; // 2 or 3
    
    float2 input_size  = float2(input.get_width(),  input.get_height());
    float2 output_size = float2(output.get_width(), output.get_height());
    
    float2 input_position = float2(output_position) * input_size / output_size;
    half4 totalColor = half4(0);
    float totalWeight = 0;
    
    for(int j = -lanczos_kernel; j < lanczos_kernel; j++) {
        for(int i = -lanczos_kernel; i < lanczos_kernel; i++) {
            float2 delta = float2(i, j);
            
            float weight = lanczosWeight(delta.x, float(lanczos_kernel))
                         * lanczosWeight(delta.y, float(lanczos_kernel));
            
            float2 pixel_position = min(max(input_position + delta, float2(0)), input_size - 1);
            
            half4 color = texture_sample_at(input, pixel_position);
            totalColor += color * half(weight);
            
            totalWeight += weight;
        }
    }
    
    half4 output_color = totalColor / half(totalWeight);
    
    output.write(output_color, output_position);
}

kernel void layer_duplicate_shift(texture2d<half, access::read>  input,
                                  texture2d<half, access::write> output,
                                  constant int2& shift,
                                  uint2 input_position [[thread_position_in_grid]]) {
    int2 output_position = int2(input_position) + shift;
    
    if (output_position.x < 0 || output_position.y < 0) return;
    
    uint2 position = uint2(output_position);
    if (position.x > output.get_width() || position.y > output.get_height()) return;
    
    half4 color = input.read(input_position);
    output.write(color, position);
}

kernel void layer_duplicate_shift_float(texture2d<half, access::sample> input,
                                        texture2d<half, access::write>  output,
                                        constant float2& shift,
                                        uint2 output_position [[thread_position_in_grid]]) {
    float2 input_position = float2(output_position) - shift;
    
    if (input_position.x < 0 || input_position.y < 0 || input_position.x > float(input.get_width()) || input_position.y > float(input.get_height())) return;
    
    half4 color = texture_sample_at(input, input_position);
    output.write(color, output_position);
}
