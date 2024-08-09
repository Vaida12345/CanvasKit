//
//  Util.metal
//  CanvasKit
//
//  Created by Vaida on 8/9/24.
//

#include "Util.h"

using namespace metal;


half4 texture_sample_at(texture2d<half, access::sample> texture, float2 position) {
    sampler mySampler(coord::pixel, address::clamp_to_zero, filter::linear);
    return texture.sample(mySampler, position + 0.5);
}
