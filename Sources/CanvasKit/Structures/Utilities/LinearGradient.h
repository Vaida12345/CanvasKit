//
//  LinearGradient.h
//  CanvasKit
//
//  Created by Vaida on 2025-09-06.
//

#ifndef LinearGradient_h
#define LinearGradient_h

#include "PartialColor.h"


struct LinearGradient {
    PartialColor startColor;
    PartialColor endColor;
    int direction;
    int _padding[3];
};

#endif /* LinearGradient_h */
