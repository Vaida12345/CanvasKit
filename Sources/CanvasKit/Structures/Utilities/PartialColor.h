
#ifndef PartialColor_H
#define PartialColor_H

struct PartialColor {
    float4 components; // SIMD, 128bit, alignment of 16.
    uint4 presence; // hence must be uint4
};

#endif // PartialColor_H
