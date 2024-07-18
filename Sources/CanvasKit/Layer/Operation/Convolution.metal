
#include <metal_stdlib>
using namespace metal;


constant int width              [[function_constant(0)]];
constant int height             [[function_constant(1)]];
constant int kernelWidth        [[function_constant(2)]];
constant int kernelHeight       [[function_constant(3)]];
constant int leftPaddingCount   [[function_constant(4)]];
constant int rightPaddingCount  [[function_constant(5)]];
constant int topPaddingCount    [[function_constant(6)]];
constant int bottomPaddingCount [[function_constant(7)]];
constant uchar layerIndexes     [[function_constant(8)]];


kernel void convolution(device const uchar* input,
                        device const float* _kernel,
                        device uchar* output,
                        uint3 index [[thread_position_in_grid]]) { // x, y, z
    if ((layerIndexes & (1 << index.z)) == 0)
        return;
    
    int colorIndex = width * index.y + index.x;
    float sum = 0;
    
    for (int i = 0; i < kernelWidth; i++) {
        for (int j = 0; j < kernelHeight; j++) {
            int deltaX = i - leftPaddingCount;
            int deltaY = j - topPaddingCount;
            
            int2 position;
            
            position[0] = index.x + deltaX;
            position[1] = index.y + deltaY;
            
            // reflective padding
            for (int k = 0; k <= 1; k++) {
                position[k] = position[k] >= 0 ? position[k] : abs(position[k]) - 1; // reflective padding
            }
            position[0] = position[0] < width  ? position[0] : width  - 1;
            position[1] = position[1] < height ? position[1] : height - 1;
            
            int colorIndex = position[1] * width + position[0];
            float color = (float) input[colorIndex * 4 + index.z];
            sum += color * _kernel[j * kernelWidth + i];
        }
    }
    
    output[colorIndex * 4 + index.z] = (uchar) sum;
}
