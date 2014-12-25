//
//  NFViewVolume.m
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import "NFViewVolume.h"

//
// TODO: NFTransform should be a generic matrix stack that will can be used
//       almost identically to the OpenGL 1.x/2.x matrix stack
//       (move class into NFUtils)
//

//static const char *g_matrixType = @encode(GLKMatrix4);

@interface NFTransform : NSObject
@property (nonatomic, assign) GLKMatrix4 computedMatrix;
@property (nonatomic, assign) BOOL dirty;
@property (nonatomic, retain) NSMutableArray* matrixStack;
@end

@implementation NFTransform
@synthesize computedMatrix = _computedMatrix;
@synthesize dirty = _dirty;
@synthesize matrixStack = _matrixStack;

- (instancetype) init {
    self = [super init];
    [self setComputedMatrix:GLKMatrix4Identity];
    [self setDirty:NO];
    return self;
}

- (void) dealloc {
    [self.matrixStack release];
    [super dealloc];
}

- (NSMutableArray *)matrixStack {
    if (_matrixStack == nil) {
        _matrixStack = [[NSMutableArray alloc] init];
    }
    return _matrixStack;
}
@end



@implementation NFViewVolume
@synthesize view = _view;
@synthesize projection = _projection;

@synthesize farPlane = _farPlane;
@synthesize nearPlane = _nearPlane;

@synthesize viewportSize = _viewportSize;
@end



/*
+ (void) updateTransform:(NFTransform *)transform {
    if ([transform dirty] == YES) {
        // should compute in reverse order for left handed coordinate systems e.g.
        // MVP = projection * view * model

        // while count > 0 loop matrix pop over the number of elements in the stack
        //id poppedMatrix = [[[self viewTransform] matrixStack] lastObject];
        //if (poppedMatrix) {
        //    [[[self viewTransform] matrixStack] removeLastObject];
        //}

        //GLKMatrix4 computedMat = GLKMatrix4Identity;

        GLKMatrix4 computedMat = [transform computedMatrix];

        for (NSValue *valueObj in [transform matrixStack]) {
            GLKMatrix4 mat;
            [valueObj getValue:&mat];

            //
            // TODO: verify the order is correct
            //

            computedMat = GLKMatrix4Multiply(computedMat, mat);
        }
        [transform setComputedMatrix:computedMat];
        [transform setDirty:NO];
    }
}

- (void) pushViewMatrix:(GLKMatrix4)mat {
    NSValue *value = [NSValue value:&mat withObjCType:g_matrixType];
    [self.viewTransform.matrixStack addObject:value];
    [self.viewTransform setDirty:YES];
}

- (void) overrideViewTransformWithMatrix:(GLKMatrix4)mat {
    [self.viewTransform.matrixStack removeAllObjects];
    [self.viewTransform setComputedMatrix:mat];
    [self.viewTransform setDirty:NO];
}
*/