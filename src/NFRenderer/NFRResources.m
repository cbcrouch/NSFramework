//
//  NFRResources.m
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#import "NFRResources.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"


@interface NFRBufferAttributes()
@property (nonatomic, assign, readwrite) GLuint hVAO;
@end

@implementation NFRBufferAttributes

- (instancetype) initWithFormat:(NF_VERTEX_FORMAT)format {
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
}

@end


@interface NFRBuffer()

@property (nonatomic, strong, readwrite) NFRBufferAttributes* bufferAttributes;

@property (nonatomic, assign, readwrite) NFR_BUFFER_TYPE bufferType;
@property (nonatomic, assign, readwrite) NFR_BUFFER_DATA_TYPE bufferDataType;
@property (nonatomic, assign, readwrite) NSUInteger numberOfElements;
@property (nonatomic, assign, readwrite) size_t bufferDataSize;
@property (nonatomic, assign, readwrite) void* bufferDataPointer;

@property (nonatomic, assign, readwrite) GLuint bufferHandle;
@end


@implementation NFRBuffer

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
}

- (void) loadData:(void*)pData ofType:(NFR_BUFFER_DATA_TYPE)dataType numberOfElements:(NSUInteger)numElements {
    self.bufferDataPointer = pData;
    self.bufferDataType = dataType;
    self.numberOfElements = numElements;

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

        case kBufferDataTypeNFScreenSpaceVertex_t:
            elementSize = sizeof(NFScreenSpaceVertex_t);
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

    self.bufferDataSize = numElements*elementSize;

    glBindBuffer(glBufferType, self.bufferHandle);
    glBufferData(glBufferType, numElements * elementSize, pData, GL_STATIC_DRAW);
    glBindBuffer(glBufferType, 0);
    CHECK_GL_ERROR();
}

@end


@interface NFRCubeMapGL()
@property (nonatomic, assign, readwrite) GLuint textureID;
@property (nonatomic, assign, readwrite) BOOL validTexture;
@end

@implementation NFRCubeMapGL

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
        glDeleteTextures(1, &texId);
    }
}

- (void) syncCubeMap:(NFRCubeMap*)cubeMap {
    GLuint texId;
    glGenTextures(1, &texId);
    self.textureID = texId;

    glBindTexture(GL_TEXTURE_CUBE_MAP, self.textureID);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

    for (int i=0; i<6; ++i) {
        GLubyte* pData = cubeMap.data[i];
        glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, cubeMap.format, cubeMap.width, cubeMap.height, 0,
                     cubeMap.format, cubeMap.type, pData);
    }

    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);

    CHECK_GL_ERROR();
    [self setValidTexture:YES];
}

- (void) activateTexture:(GLint)textureUnitNum withUniformLocation:(GLint)uniformLocation {
    glActiveTexture(textureUnitNum);
    glBindTexture(GL_TEXTURE_CUBE_MAP, self.textureID);
    glUniform1i(uniformLocation, textureUnitNum - GL_TEXTURE0);
    CHECK_GL_ERROR();
}

- (void) deactivateTexture {
    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
}

@end


@interface NFRDataMapGL()
@property (nonatomic, assign, readwrite) GLuint textureID;
@property (nonatomic, assign, readwrite) BOOL validTexture;
@end

@implementation NFRDataMapGL

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
        glDeleteTextures(1, &texId);
    }
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

    glTexImage2D(GL_TEXTURE_2D, 0, dataMap.format, dataMap.width, dataMap.height, 0,
                 dataMap.format, dataMap.type, dataMap.data);
    glBindTexture(GL_TEXTURE_2D, 0);

    CHECK_GL_ERROR();
    [self setValidTexture:YES];
}

- (void) activateTexture:(GLint)textureUnitNum withUniformLocation:(GLint)uniformLocation {
    glActiveTexture(textureUnitNum);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    glUniform1i(uniformLocation, textureUnitNum - GL_TEXTURE0);
    CHECK_GL_ERROR();
}

- (void) deactivateTexture {
    glBindTexture(GL_TEXTURE_2D, 0);
    CHECK_GL_ERROR();
}

@end


@interface NFRGeometry()
@property (nonatomic, strong, readwrite) NSMutableDictionary* textureDictionary;
@end

@implementation NFRGeometry

- (NSMutableDictionary*) textureDictionary {
    if (_textureDictionary == nil) {
        _textureDictionary = [[NSMutableDictionary alloc] init];
    }
    return _textureDictionary;
}

- (void) syncSurfaceModel {
    //
    // TODO: implement full support of the surface model
    //

    //
    // TODO: iteratre through each data map and convert it into a NFRDataMapGL
    //
    NFRDataMap *diffuseMap = (self.surfaceModel).map_Kd;

    NFRDataMapGL* mapGL = [[NFRDataMapGL alloc] init];
    [mapGL syncDataMap:diffuseMap];
    (self.textureDictionary)[@"diffuseTexture"] = mapGL;
}


//
// TODO: either remove this method since it could be used as a workaround or make it
//       officially supported (could also be used for environment mapping)
//
- (void) assignCubeMapHandle:(NSValue*)valueObj {
    (self.textureDictionary)[@"cubeMapHandle"] = valueObj;
}


- (void) assignCubeMap:(NFRCubeMap*)cubeMap {
    //
    // TODO: implement more robust support for pairing a cube map with geometry
    //

    NFRCubeMapGL* cubeMapGL = [[NFRCubeMapGL alloc] init];
    [cubeMapGL syncCubeMap:cubeMap];
    (self.textureDictionary)[@"cubeMap"] = cubeMapGL;
}

@end
