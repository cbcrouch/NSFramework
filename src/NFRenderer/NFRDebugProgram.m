//
//  NFRDebugProgram.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRDebugProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"

#import "NFRResources.h"

@implementation NFRDebugProgram

@synthesize vertexAttribute = _vertexAttribute;
@synthesize normalAttribute = _normalAttribute;
@synthesize colorAttribute = _colorAttribute;

@synthesize modelMatrixLocation = _modelMatrixLocation;

@synthesize hUBO = _hUBO;
@synthesize hProgram = _hProgram;

- (void) loadProgramInputPoints {
    // shader attributes
    [self setVertexAttribute:glGetAttribLocation(self.hProgram, "v_position")];
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    [self setNormalAttribute:glGetAttribLocation(self.hProgram, "v_normal")];
    NSAssert(self.normalAttribute != -1, @"Failed to bind attribute");

    [self setColorAttribute:glGetAttribLocation(self.hProgram, "v_color")];
    NSAssert(self.colorAttribute != -1, @"Failed to bind attribute");

    // setup uniform for model matrix
    [self setModelMatrixLocation:glGetUniformLocation(self.hProgram, (const GLchar *)"model")];
    NSAssert(self.modelMatrixLocation != -1, @"Failed to get model matrix uniform location");

    // uniform buffer for view and projection matrix
    [self setHUBO:[NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:self.hProgram]];
    NSAssert(self.hUBO != 0, @"failed to get uniform buffer handle");

    CHECK_GL_ERROR();
}

- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    glEnableVertexAttribArray(self.vertexAttribute);
    glEnableVertexAttribArray(self.normalAttribute);
    glEnableVertexAttribArray(self.colorAttribute);

    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.bufferHandle);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFDebugVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFDebugVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFDebugVertex_t, pos));
    glVertexAttribPointer(self.normalAttribute, ARRAY_COUNT(NFDebugVertex_t, norm), GL_FLOAT, GL_FALSE, sizeof(NFDebugVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFDebugVertex_t, norm));
    glVertexAttribPointer(self.colorAttribute, ARRAY_COUNT(NFDebugVertex_t, color), GL_FLOAT, GL_FALSE, sizeof(NFDebugVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFDebugVertex_t, color));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

- (void) drawGeometry:(NFRGeometry*)geometry {
    glUseProgram(self.hProgram);
    glBindVertexArray(geometry.vertexBuffer.bufferAttributes.hVAO);

    [self updateModelMatrix:geometry.modelMatrix];

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, geometry.indexBuffer.bufferHandle);
    glDrawElements(geometry.mode, (GLsizei)geometry.indexBuffer.numberOfElements, GL_UNSIGNED_SHORT, NULL);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    glBindVertexArray(0);
    glUseProgram(0);
    CHECK_GL_ERROR();
}

- (void) updateModelMatrix:(GLKMatrix4)modelMatrix {
    glProgramUniformMatrix4fv(self.hProgram, self.modelMatrixLocation, 1, GL_FALSE, modelMatrix.m);
    CHECK_GL_ERROR();
}

- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection {
    GLsizeiptr matrixSize = (GLsizeiptr)(16 * sizeof(float));
    GLintptr offset = (GLintptr)matrixSize;

    glBindBuffer(GL_UNIFORM_BUFFER, self.hUBO);

    // will allocate buffer's internal storage
    glBufferData(GL_UNIFORM_BUFFER, 2 * matrixSize, NULL, GL_STATIC_READ);

    // transfer view and projection matrix data to uniform buffer
    glBufferSubData(GL_UNIFORM_BUFFER, (GLintptr)0, matrixSize, viewMatrix.m);
    glBufferSubData(GL_UNIFORM_BUFFER, offset, matrixSize, projection.m);

    glBindBuffer(GL_UNIFORM_BUFFER, 0);
    CHECK_GL_ERROR();
}

@end
