//
//  NFRDepthProgram.m
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import "NFRDepthProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"

#import "NFRResources.h"

@implementation NFRDepthProgram

- (void) loadProgramInputPoints {

    //
    // TODO: add attribute and uniform properties
    //

/*
    // shader attributes
    self.vertexAttribute = glGetAttribLocation(self.hProgram, "v_position");
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    // setup uniform for model matrix
    self.modelMatrixLocation = glGetUniformLocation(self.hProgram, (const GLchar *)"model");
    NSAssert(self.modelMatrixLocation != -1, @"Failed to get model matrix uniform location");
*/
    CHECK_GL_ERROR();
}

- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    //glEnableVertexAttribArray(self.vertexAttribute);

    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes {
}

@end
