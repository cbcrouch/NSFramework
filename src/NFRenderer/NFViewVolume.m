//
//  NFViewVolume.m
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import "NFViewVolume.h"

static const char *g_matrixType = @encode(GLKMatrix4);

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


@interface NFViewVolume()
+ (void) updateTransform:(NFTransform *)transform;
@property (nonatomic, retain) NFTransform* viewTransform;
@property (nonatomic, retain) NFTransform* projTransform;
@end

@implementation NFViewVolume

@synthesize view = _view;
@synthesize projection = _projection;

@synthesize viewTransform = _viewTransform;
@synthesize projTransform = _projTransform;

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

- (instancetype) init {
    self = [super init];
    return self;
}

- (void) dealloc {
    [self.viewTransform release];
    [self.projTransform release];
    [super dealloc];
}

- (GLKMatrix4)view {
    [NFViewVolume updateTransform:self.viewTransform];
    return self.viewTransform.computedMatrix;
}

- (GLKMatrix4)projection {
    [NFViewVolume updateTransform:[self projTransform]];
    return self.projTransform.computedMatrix;
}

- (NFTransform *) viewTransform {
    if (_viewTransform == nil) {
        _viewTransform = [[NFTransform alloc] init];
    }
    return _viewTransform;
}

- (NFTransform *) projTransform {
    if (_projTransform == nil) {
        _projTransform = [[NFTransform alloc] init];
    }
    return _projTransform;
}

- (void) pushViewMatrix:(GLKMatrix4)mat {
    NSValue *value = [NSValue value:&mat withObjCType:g_matrixType];
    [self.viewTransform.matrixStack addObject:value];
    [self.viewTransform setDirty:YES];
}

- (void) pushProjectionMatrix:(GLKMatrix4)mat {
    NSValue *value = [NSValue value:&mat withObjCType:g_matrixType];
    [self.projTransform.matrixStack addObject:value];
    [self.projTransform setDirty:YES];
}

- (void) overrideViewTransformWithMatrix:(GLKMatrix4)mat {
    [self.viewTransform.matrixStack removeAllObjects];
    [self.viewTransform setComputedMatrix:mat];
    [self.viewTransform setDirty:NO];
}

- (void) overrideProjectionTransformWithMatrix:(GLKMatrix4)mat {
    [self.projTransform.matrixStack removeAllObjects];
    [self.projTransform setComputedMatrix:mat];
    [self.projTransform setDirty:NO];
}

- (void) updateAllTransforms {
    [NFViewVolume updateTransform:[self viewTransform]];
    [NFViewVolume updateTransform:[self projTransform]];
}

@end
