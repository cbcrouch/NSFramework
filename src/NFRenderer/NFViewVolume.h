//
//  NFViewVolume.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface NFViewVolume : NSObject
@property (nonatomic, assign) GLKMatrix4 view;
@property (nonatomic, assign) GLKMatrix4 projection;

@property (nonatomic, assign) CGFloat farPlane;
@property (nonatomic, assign) CGFloat nearPlane;

@property (nonatomic, assign) CGSize viewportSize;
@end
