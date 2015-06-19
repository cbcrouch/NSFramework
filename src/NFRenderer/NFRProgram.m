//
//  NFRProgram.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"



@interface NFRBufferAttributes()
@property (nonatomic, assign, readwrite) GLuint hVAO;
@end

@implementation NFRBufferAttributes

@synthesize hVAO = _hVAO;

- (instancetype) initWithFormat:(NFR_VERTEX_FORMAT)format {
    self = [super init];
    if (self != nil) {
        GLuint vao;
        glGenVertexArrays(1, &vao);
        _hVAO = vao;
        _format = format;
    }

    return self;
}

- (void) dealloc {
    GLuint vao = _hVAO;
    glDeleteVertexArrays(1, &vao);
    [super dealloc];
}

@end



@interface NFRBuffer()

@property (nonatomic, retain, readwrite) NFRBufferAttributes* bufferAttributes;

@property (nonatomic, assign, readwrite) NFR_BUFFER_TYPE bufferType;
@property (nonatomic, assign, readwrite) NFR_BUFFER_DATA_TYPE bufferDataType;
@property (nonatomic, assign, readwrite) NSUInteger numberOfElements;
@property (nonatomic, assign, readwrite) size_t bufferDataSize;
@property (nonatomic, assign, readwrite) void* bufferDataPointer;

@property (nonatomic, assign) GLuint bufferHandle;
@end


@implementation NFRBuffer

@synthesize bufferAttributes = _bufferAttributes;

@synthesize bufferType = _bufferType;
@synthesize bufferDataType = _bufferDataType;
@synthesize numberOfElements = _numberOfElements;
@synthesize bufferDataSize = _bufferDataSize;
@synthesize bufferDataPointer = _bufferDataPointer;

@synthesize bufferHandle = _bufferHandle;

- (instancetype) initWithType:(NFR_BUFFER_TYPE)type usingAttributes:(NFRBufferAttributes*)bufferAttributes {
    self = [super init];
    if (self != nil) {
        _bufferType = type;
        _bufferAttributes = bufferAttributes;
        glBindVertexArray(_bufferAttributes.hVAO);
        switch (_bufferType) {
            case kBufferTypeVertex: {
                // create vertex buffer object
                GLuint vbo;
                glGenBuffers(1, &vbo);
                self.bufferHandle = vbo;
            } break;

            case kBufferTypeIndex: {
                // create element buffer object
                GLuint ebo;
                glGenBuffers(1, &ebo);
                self.bufferHandle = ebo;
            } break;
                
            default:
                NSLog(@"WARNING: NFRBuffer initialized with unknown buffer type, no OpenGL buffer handle created");
                break;
        }
        glBindVertexArray(0);
        CHECK_GL_ERROR();
    }
    return self;
}

- (void) dealloc {
    GLuint hBuffer = self.bufferHandle;
    glDeleteBuffers(1, &hBuffer);
    [super dealloc];
}

- (void) loadData:(void*)pData ofType:(NFR_BUFFER_DATA_TYPE)dataType numberOfElements:(NSUInteger)numElements {
    [self setBufferDataPointer:pData];
    [self setBufferDataType:dataType];
    [self setNumberOfElements:numElements];

    GLsizeiptr elementSize;
    GLenum glBufferType;
    switch (dataType) {
        case kBufferDataTypeNFVertex_t:
            elementSize = sizeof(NFVertex_t);
            glBufferType = GL_ARRAY_BUFFER;
            break;

        case kBufferDataTypeNFDebugVertex_t:
            elementSize = sizeof(NFDebugVertex_t);
            glBufferType = GL_ARRAY_BUFFER;
            break;

        case kBufferDataTypeUShort:
            elementSize = sizeof(GLushort);
            glBufferType = GL_ELEMENT_ARRAY_BUFFER;
            break;

        default:
            elementSize = 0;
            glBufferType = GL_INVALID_ENUM;
            break;
    }

    [self setBufferDataSize:numElements*elementSize];

    glBindBuffer(glBufferType, self.bufferHandle);
    glBufferData(glBufferType, numElements * elementSize, pData, GL_STATIC_DRAW);
    glBindBuffer(glBufferType, 0);
    CHECK_GL_ERROR();
}

@end




@interface NFRDataMapGL : NSObject

@property (nonatomic, assign, readonly) GLuint textureID;
@property (nonatomic, retain) NFRDataSampler* sampler;

@property (nonatomic, assign, readonly, getter=isTextureValid) BOOL validTexture;

- (void) syncDataMap:(NFRDataMap*)dataMap;

- (void) activateTexture:(GLint)textureUnitNum withUniformLocation:(GLint)uniformLocation;
- (void) deactivateTexture;

@end


@interface NFRDataMapGL()
@property (nonatomic, assign, readwrite) GLuint textureID;
@property (nonatomic, assign, readwrite) BOOL validTexture;
@end

@implementation NFRDataMapGL

@synthesize textureID = _textureID;

- (instancetype) init {
    self = [super init];
    if (self) {
        _validTexture = NO;
    }
    return self;
}

- (void) dealloc {
    if (self.isTextureValid) {
        GLuint texId = self.textureID;
        glDeleteTextures(1, &(texId));
    }
    [super dealloc];
}

- (void) syncDataMap:(NFRDataMap*)dataMap {
    GLuint texId;
    glGenTextures(1, &texId);
    self.textureID = texId;

    glBindTexture(GL_TEXTURE_2D, self.textureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, [dataMap format], [dataMap width], [dataMap height], 0,
                 [dataMap format], [dataMap type], [dataMap data]);
    glBindTexture(GL_TEXTURE_2D, 0);

    CHECK_GL_ERROR();
    [self setValidTexture:YES];
}

- (void) activateTexture:(GLint)textureUnitNum withUniformLocation:(GLint)uniformLocation {
    glActiveTexture(textureUnitNum);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    glUniform1i(uniformLocation, textureUnitNum);
    CHECK_GL_ERROR();
}

- (void) deactivateTexture {
    glBindTexture(GL_TEXTURE_2D, 0);
    CHECK_GL_ERROR();
}

@end




@interface NFRGeometry()
@property (nonatomic, retain, readwrite) NSDictionary* textureDictionary;
@end


@implementation NFRGeometry

@synthesize vertexBuffer = _vertexBuffer;
@synthesize indexBuffer = _indexBuffer;
@synthesize surfaceModel = _surfaceModel;
@synthesize textureDictionary = _textureDictionary;

- (NSDictionary*) textureDictionary {
    if (_textureDictionary == nil) {
        _textureDictionary = [[[NSDictionary alloc] init] autorelease];
    }
    return _textureDictionary;
}


//
// TODO: implement a method to convert the data map array into the corresponding
//       OpenGL objects
//
- (void) syncDataMapArray {
    //
    // TODO: iteratre through each data map and convert it into a NFRDataMapGL
    //
    NFRDataMap *diffuseMap = [self.surfaceModel map_Kd];

    NFRDataMapGL* mapGL = [[[NFRDataMapGL alloc] init] autorelease];
    [mapGL syncDataMap:diffuseMap];


    NSString* uniformName = @"diffuseTexture";


    // make sure that the textureDictionary will hold onto the mapGL reference
    [self.textureDictionary insertValue:mapGL inPropertyWithKey:uniformName];


    // for the drawing code, program will need access to the texture dictionary
    // (should be able to draw no problem without a surface model or any textures)
/*
    for (id key in textureDictionary) {
        NFRDataMapGL* textureGL = [textureDictionary objectForKey:key];
        // pass uniform location and texture unit num based on key string
        [textureGL activateTexture:GL_TEXTURE0 withUniformLocation:program.textureUniform];
    }

    // draw..

    // if debug then deactivate all textures
    for (id key in textureDictionary) {
        NFRDataMapGL* textureGL = [textureDictionary objectForKey:key];
        [textureGL deactivateTexture];
    }
*/
}

@end




@interface NFRPhongProgram : NSObject <NFRProgram>

typedef struct phongMaterialUniform_t {
    GLint ambientLoc;
    GLint diffuseLoc;
    GLint specularLoc;
    GLint shineLoc;
} phongMaterialUniform_t;

typedef struct phongLightUniform_t {
    GLint ambientLoc;
    GLint diffuseLoc;
    GLint specularLoc;
    GLint positionLoc;
} phongLightUniform_t;

@property (nonatomic, assign) GLint vertexAttribute;
@property (nonatomic, assign) GLint normalAttribute;
@property (nonatomic, assign) GLint texCoordAttribute;

@property (nonatomic, assign) phongMaterialUniform_t materialUniforms;
@property (nonatomic, assign) phongLightUniform_t lightUniforms;

@property (nonatomic, assign) GLint modelMatrixLocation;
@property (nonatomic, assign) GLint viewPositionLocation;
@property (nonatomic, assign) GLuint lightSubroutine;
@property (nonatomic, assign) GLuint phongSubroutine;

@property (nonatomic, assign) GLuint hUBO;

@property (nonatomic, readwrite, assign) GLuint hProgram;

- (void) loadProgramInputPoints;

@end

@implementation NFRPhongProgram

@synthesize vertexAttribute = _vertexAttribute;
@synthesize normalAttribute = _normalAttribute;
@synthesize texCoordAttribute = _texCoordAttribute;

@synthesize materialUniforms = _materialUniforms;
@synthesize lightUniforms = _lightUniforms;

@synthesize modelMatrixLocation = _modelMatrixLocation;
@synthesize viewPositionLocation = _viewPositionLocation;
@synthesize lightSubroutine = _lightSubroutine;
@synthesize phongSubroutine = _phongSubroutine;

@synthesize hUBO = _hUBO;

- (void) loadProgramInputPoints {
    // shader attributes
    [self setVertexAttribute:glGetAttribLocation(self.hProgram, "v_position")];
    NSAssert(self.vertexAttribute != -1, @"Failed to bind attribute");

    [self setNormalAttribute:glGetAttribLocation(self.hProgram, "v_normal")];
    NSAssert(self.normalAttribute != -1, @"Failed to bind attribute");

    [self setTexCoordAttribute:glGetAttribLocation(self.hProgram, "v_texcoord")];
    NSAssert(self.texCoordAttribute != -1, @"Failed to bind attribute");

    // material struct uniform locations
    phongMaterialUniform_t phongMat;

    phongMat.ambientLoc = glGetUniformLocation(self.hProgram, "material.ambient");
    NSAssert(phongMat.ambientLoc != -1, @"failed to get uniform location");

    phongMat.diffuseLoc = glGetUniformLocation(self.hProgram, "material.diffuse");
    NSAssert(phongMat.diffuseLoc != -1, @"failed to get uniform location");

    phongMat.specularLoc = glGetUniformLocation(self.hProgram, "material.specular");
    NSAssert(phongMat.specularLoc != -1, @"failed to get uniform location");

    phongMat.shineLoc = glGetUniformLocation(self.hProgram, "material.shininess");
    NSAssert(phongMat.shineLoc != -1, @"failed to get uniform location");

    [self setMaterialUniforms:phongMat];

    // hardcoded material values (jade)
    glUseProgram(self.hProgram);
    glUniform3f(phongMat.ambientLoc, 0.135f, 0.2225f, 0.1575f);
    glUniform3f(phongMat.diffuseLoc, 0.54f, 0.89f, 0.63f);
    glUniform3f(phongMat.specularLoc, 0.316228f, 0.316228f, 0.316228f);
    glUniform1f(phongMat.shineLoc, 128.0f * 0.1f);
    glUseProgram(0);

    // light struct uniform locations
    phongLightUniform_t phongLight;
    phongLight.ambientLoc = glGetUniformLocation(self.hProgram, "light.ambient");
    NSAssert(phongLight.ambientLoc != -1, @"failed to get uniform location");

    phongLight.diffuseLoc = glGetUniformLocation(self.hProgram, "light.diffuse");
    NSAssert(phongLight.diffuseLoc != -1, @"failed to get uniform location");

    phongLight.specularLoc = glGetUniformLocation(self.hProgram, "light.specular");
    NSAssert(phongLight.specularLoc != -1, @"failed to get uniform location");

    phongLight.positionLoc = glGetUniformLocation(self.hProgram, "light.position");
    NSAssert(phongLight.positionLoc != -1, @"failed to get uniform location");

    [self setLightUniforms:phongLight];

    // hardcoded light values
    glUseProgram(self.hProgram);
    glUniform3f(phongLight.ambientLoc, 0.2f, 0.2f, 0.2f);
    glUniform3f(phongLight.diffuseLoc, 0.5f, 0.5f, 0.5f);
    glUniform3f(phongLight.specularLoc, 1.0f, 1.0f, 1.0f);
    glUniform3f(phongLight.positionLoc, 2.0f, 1.0f, 0.0f);
    glUseProgram(0);

    // model matrix uniform location
    [self setModelMatrixLocation:glGetUniformLocation(self.hProgram, (const GLchar *)"model")];
    NSAssert(self.modelMatrixLocation != -1, @"failed to get model matrix uniform location");

    // view position uniform location
    [self setViewPositionLocation:glGetUniformLocation(self.hProgram, "viewPos")];
    NSAssert(self.viewPositionLocation != -1, @"failed to get uniform location");

    // subroutine indices
    [self setLightSubroutine:glGetSubroutineIndex(self.hProgram, GL_FRAGMENT_SHADER, "light_subroutine")];
    NSAssert(self.lightSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");

    [self setPhongSubroutine:glGetSubroutineIndex(self.hProgram, GL_FRAGMENT_SHADER, "phong_subroutine")];
    NSAssert(self.phongSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");

    // uniform buffer for view and projection matrix
    [self setHUBO:[NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:self.hProgram]];
    NSAssert(self.hUBO != 0, @"failed to get uniform buffer handle");

    CHECK_GL_ERROR();
}


//
// TODO: protocol region
//

@synthesize hProgram = _hProgram;


//
// TODO: pass in an NFRBufferAttributes object and consider storing the attirbutes in the object itself
//
- (void) configureInputState:(GLint)hVAO {
    glBindVertexArray(hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    glEnableVertexAttribArray(self.vertexAttribute);
    glEnableVertexAttribArray(self.normalAttribute);
    glEnableVertexAttribArray(self.texCoordAttribute);

    glBindVertexArray(0);
    CHECK_GL_ERROR();
}


//
// TODO: these functions should not be a part of the program object
//
- (void) configureVertexBufferLayout:(GLint)hVBO withVAO:(GLint)hVAO {
    glBindVertexArray(hVAO);
    glBindBuffer(GL_ARRAY_BUFFER, hVBO);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, pos));
    glVertexAttribPointer(self.normalAttribute, ARRAY_COUNT(NFVertex_t, norm), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, norm));
    glVertexAttribPointer(self.texCoordAttribute, ARRAY_COUNT(NFVertex_t, texCoord), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, texCoord));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

- (void) updateVertexBuffer:(GLint)hVBO numVertices:(GLuint)numVertices dataPtr:(void*)pData {
    glBindBuffer(GL_ARRAY_BUFFER, hVBO);
    glBufferData(GL_ARRAY_BUFFER, numVertices * sizeof(NFVertex_t), pData, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    CHECK_GL_ERROR();
}

- (void) updateIndexBuffer:(GLint)hEBO numIndices:(GLuint)numIndices dataPtr:(void*)pData {
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, hEBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numIndices * sizeof(GLushort), pData, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    CHECK_GL_ERROR();
}



- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    glEnableVertexAttribArray(self.vertexAttribute);
    glEnableVertexAttribArray(self.normalAttribute);
    glEnableVertexAttribArray(self.texCoordAttribute);

    glBindVertexArray(0);
    CHECK_GL_ERROR();

}
- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes {
    glBindVertexArray(bufferAttributes.hVAO);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.bufferHandle);

    glVertexAttribPointer(self.vertexAttribute, ARRAY_COUNT(NFVertex_t, pos), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, pos));
    glVertexAttribPointer(self.normalAttribute, ARRAY_COUNT(NFVertex_t, norm), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, norm));
    glVertexAttribPointer(self.texCoordAttribute, ARRAY_COUNT(NFVertex_t, texCoord), GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, texCoord));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

//
//
//


- (void) updateModelMatrix:(GLKMatrix4)modelMatrix {
    glProgramUniformMatrix4fv(self.hProgram, self.modelMatrixLocation, 1, GL_FALSE, modelMatrix.m);
    CHECK_GL_ERROR();
}

- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection {

    //
    // TODO: while not yet implemented should consider using some additional utility method(s)
    //       for simplfying UBOs to avoid redundant code between shader program implementations
    //
/*
    static const char* matrixType = @encode(GLKMatrix4);
    NSMutableArray* matrixArray = [[[NSMutableArray alloc] init] autorelease];
    [matrixArray addObject:[NSValue value:&viewMatrix withObjCType:matrixType]];
    [matrixArray addObject:[NSValue value:&projection withObjCType:matrixType]];

    //
    // TODO: this utility method has not been tested
    //
    [NFRUtils setUniformBuffer:self.hUBO withData:matrixArray];
*/


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

- (void)activateSubroutine:(NSString *)subroutine {
    if ([subroutine isEqualToString:@"PhongSubroutine"]) {
        GLuint phongSubroutine = self.phongSubroutine;
        glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &(phongSubroutine));
    }
    else if ([subroutine isEqualToString:@"LightSubroutine"]) {
        GLuint lightSubroutine = self.lightSubroutine;
        glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &(lightSubroutine));
    }
    else {
        NSLog(@"WARNING: NFRPhongProgram recieved unknown subroutine name in activeSubroutine method, no subroutine bound");
    }
}

- (void) updateViewPosition:(GLKVector3)viewPosition {
    glUseProgram(self.hProgram);
    glUniform3f(self.viewPositionLocation, viewPosition.x, viewPosition.y, viewPosition.z);
    glUseProgram(0);
    CHECK_GL_ERROR();
}

@end


@interface NFRDebugProgram : NSObject <NFRProgram>

@property (nonatomic, assign) GLint vertexAttribute;
@property (nonatomic, assign) GLint normalAttribute;
@property (nonatomic, assign) GLint colorAttribute;

@property (nonatomic, assign) GLint modelMatrixLocation;

@property (nonatomic, assign) GLuint hUBO;

@property (nonatomic, readwrite, assign) GLuint hProgram;

- (void) loadProgramInputPoints;

@end

@implementation NFRDebugProgram

@synthesize vertexAttribute = _vertexAttribute;
@synthesize normalAttribute = _normalAttribute;
@synthesize colorAttribute = _colorAttribute;

@synthesize modelMatrixLocation = _modelMatrixLocation;

@synthesize hUBO = _hUBO;


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


@synthesize hProgram = _hProgram;



- (void) configureInputState:(GLint)hVAO {
    glBindVertexArray(hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    glEnableVertexAttribArray(self.vertexAttribute);
    glEnableVertexAttribArray(self.normalAttribute);
    glEnableVertexAttribArray(self.colorAttribute);

    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

- (void) configureVertexBufferLayout:(GLint)hVBO withVAO:(GLint)hVAO {
    glBindVertexArray(hVAO);
    glBindBuffer(GL_ARRAY_BUFFER, hVBO);

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




- (void) updateVertexBuffer:(GLint)hVBO numVertices:(GLuint)numVertices dataPtr:(void*)pData {
    glBindBuffer(GL_ARRAY_BUFFER, hVBO);
    glBufferData(GL_ARRAY_BUFFER, numVertices * sizeof(NFDebugVertex_t), pData, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    CHECK_GL_ERROR();
}

- (void) updateIndexBuffer:(GLint)hEBO numIndices:(GLuint)numIndices dataPtr:(void*)pData {
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, hEBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numIndices * sizeof(GLushort), pData, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
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


@implementation NFRProgram

+ (id<NFRProgram>) createProgramObject:(NSString *)programName {

    if ([programName isEqualToString:@"DefaultModel"]) {
        NFRPhongProgram* programObj = [[[NFRPhongProgram alloc] init] autorelease];
        [programObj setHProgram:[NFRUtils createProgram:programName]];
        [programObj loadProgramInputPoints];
        return programObj;
    }
    else if ([programName isEqualToString:@"Debug"]) {
        NFRDebugProgram* programObj = [[[NFRDebugProgram alloc] init] autorelease];
        [programObj setHProgram:[NFRUtils createProgram:programName]];
        [programObj loadProgramInputPoints];
        return programObj;
    }
    else {
        NSLog(@"WARNING: NFRUtils createProgramObject attempted to load an unknown program, returning nil");
    }
    
    return nil;
}

@end

