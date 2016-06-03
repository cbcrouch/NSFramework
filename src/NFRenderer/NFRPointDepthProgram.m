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
    self.modelMatrixLocation = glGetUniformLocation(self.hProgram, "model");
    NSAssert(self.modelMatrixLocation != -1, @"Failed to get uniform location");

    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    for (int i=0; i<6; ++i) {
        NSString* uniformStr = [NSString stringWithFormat:@"shadowTransforms[%d]", i];
        GLint transformLocation = glGetUniformLocation(self.hProgram, [uniformStr UTF8String]);
        NSAssert(transformLocation != -1, @"Failed to get uniform location");
        [tempArray addObject:@(transformLocation)];
    }
    self.shadowTransformsArray = [[NSArray alloc] initWithArray:tempArray];

    self.lightPositionLocation = glGetUniformLocation(self.hProgram, "lightPos");
    NSAssert(self.lightPositionLocation != -1, @"Failed to get uniform location");

    self.farPlaneLocation = glGetUniformLocation(self.hProgram, "farPlane");
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
    // TODO: implement
    //
    NSLog(@"WARNING: NFRPointDepthProgram drawGeometry called but not implemented");
}

//
// TODO: try using glUniform* instead of glProgramUniform* as it could be faster
//

- (void) updateFarPlane:(NSNumber*)value {
    GLfloat farPlane = [value floatValue];
    glProgramUniform1f(self.hProgram, self.farPlaneLocation, farPlane);
    CHECK_GL_ERROR();
}

- (void) updateLightPosition:(NSValue*)valueObject {
    GLKVector3 lightPosition;
    [valueObject getValue:&lightPosition];
    glProgramUniform3f(self.hProgram, self.lightPositionLocation, lightPosition.x, lightPosition.y, lightPosition.z);
    CHECK_GL_ERROR();
}

- (void) updateCubeMapTransforms:(NSArray*)objArray {
    for (int i=0; i<6; ++i) {
        GLint tempLocation = (GLint)[self.shadowTransformsArray[i] integerValue];
        NSAssert(tempLocation != -1, @"Failed to get uniform location");

        GLKMatrix4 cubeMapTransform;
        NSValue* valueObj = [objArray objectAtIndex:i];
        [valueObj getValue:&cubeMapTransform];

        glProgramUniformMatrix4fv(self.hProgram, tempLocation, 1, GL_FALSE, cubeMapTransform.m);
    }
    CHECK_GL_ERROR();
}

- (void) updateModelMatrix:(GLKMatrix4)modelMatrix {
    glProgramUniformMatrix4fv(self.hProgram, self.modelMatrixLocation, 1, GL_FALSE, modelMatrix.m);
    CHECK_GL_ERROR();
}

@end
