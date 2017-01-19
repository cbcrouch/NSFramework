//
//  NFRPointDepthProgram.h
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTE: because both gl.h and gl3.h are included will get symbols for deprecated GL functions
//       and they should absolutely not be used
#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>


#import "NFRProgramProtocol.h"


@interface NFRPointDepthProgram : NSObject <NFRProgram>

@property (nonatomic, readwrite, assign) GLuint hProgram;

// vertex shader
@property (nonatomic, assign) GLint vertexAttribute;
@property (nonatomic, assign) GLint modelMatrixLocation;

// geometry shader
@property (nonatomic, retain) NSArray* shadowTransformsArray;

// fragment shader
@property (nonatomic, assign) GLint lightPositionLocation;
@property (nonatomic, assign) GLint farPlaneLocation;


- (void) updateFarPlane:(NSNumber*)value;
- (void) updateLightPosition:(NSValue*)valueObject;
- (void) updateCubeMapTransforms:(NSArray*)objArray;

@end
