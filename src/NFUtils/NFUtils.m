//
//  NFUtils.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFUtils.h"

//@interface NFUtils ()
//@end

@implementation NFUtils

+ (GLKQuaternion) rotateVector:(GLKVector3)vector toDirection:(GLKVector3)directionVec {
    float cosTheta = GLKVector3DotProduct(vector, directionVec);
    GLKVector3 rotationAxis;
    GLKQuaternion rotationQuat;

    if (cosTheta < -1.0f + FLT_EPSILON) {
        //
        // TODO: this code path has not been tested
        //
        NSLog(@"WARNING: cosTheta < -1.0f code path has not been tested");

        rotationAxis = GLKVector3CrossProduct(GLKVector3Make(0.0f, 0.0f, 1.0f), vector);

        if (GLKVector3Length(rotationAxis) < FLT_EPSILON) {
            rotationAxis = GLKVector3CrossProduct(GLKVector3Make(1.0f, 0.0f, 0.0f), vector);
        }

        rotationQuat = GLKQuaternionMakeWithAngleAndVector3Axis(M_PI, GLKVector3Normalize(rotationAxis));
    }
    else {
        rotationAxis = GLKVector3CrossProduct(vector, directionVec);

        GLKVector3Normalize(rotationAxis); // not sure if needed

        float s = sqrtf((1.0f + cosTheta) * 2.0f);
        float invs = 1.0f / s;
        rotationQuat = GLKQuaternionMake(rotationAxis.x * invs, rotationAxis.y * invs, rotationAxis.z * invs, s * 0.5f);
    }

    return rotationQuat;
}

@end
