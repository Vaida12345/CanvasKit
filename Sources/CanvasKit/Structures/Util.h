//
//  Util.h
//  CanvasKit
//
//  Created by Vaida on 8/9/24.
//

#ifndef UTIL_H
#define UTIL_H

#include <metal_stdlib>

using namespace metal;

half4 texture_sample_at(texture2d<half, access::sample> texture, float2 position);

#endif // UTIL_H
