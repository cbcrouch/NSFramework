//
//  NFRDirectionalDepthProgram.h
//  NSFramework
//
//  Copyright © 2017 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTE: because both gl.h and gl3.h are included will get symbols for deprecated GL functions
//       and they should absolutely not be used
#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>


#import "NFRProgramProtocol.h"


@interface NFRDirectionalDepthProgram : NSObject <NFRProgram>

@property (nonatomic, assign) GLint vertexAttribute;

@property (nonatomic, assign) GLint projectionViewLocation;
@property (nonatomic, assign) GLint modelMatrixLocation;

@property (nonatomic, readwrite, assign) GLuint hProgram;

@end
