//
//  NFUtils.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTE: "the abstime unit is equal to the length of one bus cycle" according to Mach documentation

typedef uint64_t MACH_TIME;

#ifdef DEBUG
#define GET_MACH_TIME() CVGetCurrentHostTime() // returns MACH_TIME
#else
#define GET_MACH_TIME() // no-op when building a release version
#endif

#ifdef DEBUG
#define LOG_MACH_TIME_DELTA(TIME_STAMP) NSLog(@"time diff: %f micro seconds", \
    (CVGetCurrentHostTime() - TIME_STAMP) / CVGetHostClockFrequency())
#else
#define LOG_MACH_TIME_DELTA() // no-op when building a release version
#endif


static NSArray * (^convertCfloatArrayToNS)(float[3]) = ^ NSArray * (float triplet[3]) {
    NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
    NSNumber *tempNum;
    for (int i=0; i<3; ++i) {
        tempNum = [NSNumber numberWithFloat:triplet[i]];
        [tempArray addObject:tempNum];
    }
    return [[tempArray copy] autorelease];
};


//
// TODO: NFMotionVector implementation should be moved to the animation module
//

//@interface NFMotionVector : NSObject
//@property(nonatomic, assign) GLKVector4 vector;
//@property(nonatomic, assign) NSInteger rate;
//@end


@interface NFUtils : NSObject

@end


/*
 @interface NFArcBall : NSObject

 @property (nonatomic, assign) NSInteger lastX;
 @property (nonatomic, assign) NSInteger lastY;
 @property (nonatomic, assign) NSInteger currentX;
 @property (nonatomic, assign) NSInteger currentY;

 @property (nonatomic, assign) CGSize viewportSize;
 @property (nonatomic, assign) BOOL active;

 //
 // TODO: need to lock the arc ball while computing the rotation matrix
 //       (i.e. this will need to be made thread safe)
 //
 - (GLKMatrix4) getRotationMatrix;

 @end

 @interface NFArcBall()

 - (GLKVector4) getVectorWithX:(NSInteger)x withY:(NSInteger)y;

 @end

 @implementation NFArcBall

 - (instancetype) init {
 self = [super init];
 if (self != nil) {
 [self setLastX:0];
 [self setLastY:0];
 [self setCurrentX:0];
 [self setCurrentY:0];
 [self setViewportSize:CGSizeMake(0.0f, 0.0f)];
 [self setActive:NO];
 }
 return self;
 }

 - (GLKVector4) getVectorWithX:(NSInteger)x withY:(NSInteger)y {

 //
 // TODO: this method has not yet been tested and can drop usage
 //       of the multiplicative identity
 //

 GLKVector4 P = GLKVector4Make(1.0f * (x / self.viewportSize.width) * 2.0f - 1.0f,
 1.0f * (y / self.viewportSize.height) * 2.0f -1.0f,
 0.0f, 0.0f);
 P.y = -P.y;

 float opSquare = (P.x * P.x) + (P.y * P.y);
 if (opSquare <= 1.0f) {
 P.z = sqrtf(1.0f - opSquare);
 }
 else {
 P = GLKVector4Normalize(P);
 }

 return P;
 }

 //
 // TODO: this arc ball calculation is to rotate an object, not the camera, will need to modify
 //       to work with the NFCamera class (but will still want the ability to generate a rotation
 //       matrix in order to manipulate various geometry in the scene)
 //

 - (GLKMatrix4) getRotationMatrix {

 //
 // TODO: convert snippet from wikibook to ObjC
 //


 GLKVector4 va = [self getVectorWithX:self.lastX withY:self.lastY];
 GLKVector4 vb = [self getVectorWithX:self.currentX withY:self.currentY];

 float angle = acosf(min(1.0f, GLKVector4DotProduct(va, vb)));
 GLKVector4 axisCameraCoord = GLKVector4CrossProduct(va, vb);


 //
 // TODO: what is transforms[MODE_CAMERA] and objectToWorld set as ??
 //

 //GLKMatrix4 cameraToObject = GLKMatrix4Invert(transfroms[MODE_CAMERA] * objectToWorld, NO);
 //GLKVector4 axisObjectCoord = cameraToObject * axisCameraCoord;

 //GLKMatrix4 = GLKMatrix4Rotate(originalMatrix, angle, axisObjectCoord.x, axisObjectCoord.y, axisObjectCoord.z);


 self.lastX = self.currentX;
 self.lastY = self.currentY;

 #if 0
 glm::vec3 va = get_arcball_vector(last_mx, last_my);
 glm::vec3 vb = get_arcball_vector( cur_mx,  cur_my);

 float angle = acos(min(1.0f, glm::dot(va, vb)));

 glm::vec3 axis_in_camera_coord = glm::cross(va, vb);

 glm::mat3 camera2object = glm::inverse(glm::mat3(transforms[MODE_CAMERA]) * glm::mat3(mesh.object2world));
 glm::vec3 axis_in_object_coord = camera2object * axis_in_camera_coord;

 mesh.object2world = glm::rotate(mesh.object2world, glm::degrees(angle), axis_in_object_coord);

 last_mx = cur_mx;
 last_my = cur_my;
 #endif

 return GLKMatrix4Make(0.0f, 0.0f, 0.0f, 0.0f,
 0.0f, 0.0f, 0.0f, 0.0f,
 0.0f, 0.0f, 0.0f, 0.0f,
 0.0f, 0.0f, 0.0f, 0.0f);

 }

 @end
 */
