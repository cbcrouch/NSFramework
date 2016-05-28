//
//  NFRPointDepthProgram.m
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import "NFRPointDepthProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"

#import "NFRResources.h"


@implementation NFRPointDepthProgram

- (void) loadProgramInputPoints {
    // shader attributes
    self.vertexAttribute = glGetAttribLocation(self.hProgram, "v_position");
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    // shader uniforms
    self.modelMatrixLocation = glGetUniformLocation(self.hProgram, (const GLchar *)"model");
    NSAssert(self.modelMatrixLocation != -1, @"Failed to get uniform location");

    self.shadowTransformsLocation = glGetUniformLocation(self.hProgram, (const GLchar *)"shadowTransforms");
    NSAssert(self.shadowTransformsLocation != -1, @"Failed to get uniform location");

    self.lightPositionLocation = glGetUniformLocation(self.hProgram, (const GLchar *)"lightPos");
    NSAssert(self.lightPositionLocation != -1, @"Failed to get uniform location");

    self.farPlaneLocation = glGetUniformLocation(self.hProgram, (const GLchar *)"farPlane");
    NSAssert(self.farPlaneLocation != -1, @"Failed to get uniform location");

    CHECK_GL_ERROR();
}

- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);
    glEnableVertexAttribArray(self.vertexAttribute);
    glBindVertexArray(0);

    CHECK_GL_ERROR();
}

- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.bufferHandle);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, pos));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    CHECK_GL_ERROR();
}

- (void) drawGeometry:(NFRGeometry*)geometry {
    //
}

- (void) updateFarPlane:(GLfloat)farPlane {
    //
}

- (void) updateLightPosition:(GLKVector3)lightPosition {
    //
}

- (void) updateCubeMapTransforms:(GLKMatrix4[6])cubeMapTransforms {

    //
    // TODO: set shadow transforms for point depth cube map
    //

}

- (void) updateModelMatrix:(GLKMatrix4)modelMatrix {
    glProgramUniformMatrix4fv(self.hProgram, self.modelMatrixLocation, 1, GL_FALSE, modelMatrix.m);
    CHECK_GL_ERROR();
}

@end
