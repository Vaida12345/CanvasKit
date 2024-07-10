//
//  Transform + Resize.metal
//  
//
//  Created by Vaida on 7/10/24.
//

#include <metal_stdlib>
using namespace metal;


// Define the size of the Lanczos kernel.
constant int lanczos_kernel [[function_constant(0)]]; // 2 or 3, commonly used values for Lanczos resampling
constant int inputWidth     [[function_constant(1)]];
constant int inputHeight    [[function_constant(2)]];
constant int outputWidth    [[function_constant(3)]];
constant int outputHeight   [[function_constant(4)]];

// Define a utility function to calculate the Lanczos kernel weight.
float lanczosWeight(float x) {
    if (x == 0.0) return 1.0;
    if (abs(x) >= float(lanczos_kernel)) return 0.0;
    float pi_x = 3.14159265358979323846 * x;
    return lanczos_kernel * sin(pi_x) * sin(pi_x / float(lanczos_kernel)) / (pi_x * pi_x);
}


kernel void lanczosResample(const device uint8_t* inputBuffer,
                            device uint8_t* outputBuffer,
                            uint2 index [[thread_position_in_grid]]) {
    int yOut = int(index.y);
    int xOut = int(index.x);
    
    float xIn = float(xOut) * float(inputWidth) / float(outputWidth);
    float yIn = float(yOut) * float(inputHeight) / float(outputHeight);
    
    float totalR = 0;
    float totalG = 0;
    float totalB = 0;
    float totalA = 0;
    float totalWeight = 0;
    
    int inputBaseX = int(xIn);
    int inputBaseY = int(yIn);
    
    for(int j = -lanczos_kernel; j < lanczos_kernel; j++) {
        for(int i = -lanczos_kernel; i < lanczos_kernel; i++) {
            float weight = lanczosWeight(float(i) - (xIn - float(inputBaseX))) * lanczosWeight(float(j) - (yIn - float(inputBaseY)));
            int pixelX = min(max(inputBaseX + i, 0), inputWidth - 1);
            int pixelY = min(max(inputBaseY + j, 0), inputHeight - 1);
            int pixelIndex = (pixelY * inputWidth + pixelX) * 4;
            
            totalR += float(inputBuffer[pixelIndex]) * weight;
            totalG += float(inputBuffer[pixelIndex + 1]) * weight;
            totalB += float(inputBuffer[pixelIndex + 2]) * weight;
            totalA += float(inputBuffer[pixelIndex + 3]) * weight;
            totalWeight += weight;
        }
    }
    
    float outputR = totalR / totalWeight;
    float outputG = totalG / totalWeight;
    float outputB = totalB / totalWeight;
    float outputA = totalA / totalWeight;
    
    // Write the color components to the output buffer
    int outputIndex = (yOut * outputWidth + xOut) * 4;
    outputBuffer[outputIndex] = uint8_t(outputR);
    outputBuffer[outputIndex + 1] = uint8_t(outputG);
    outputBuffer[outputIndex + 2] = uint8_t(outputB);
    outputBuffer[outputIndex + 3] = uint8_t(outputA);
}
