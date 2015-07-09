//
//  NFRResources.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRResources.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"

@interface NFRBufferAttributes()
@property (nonatomic, assign, readwrite) GLuint hVAO;
@end

@implementation NFRBufferAttributes

@synthesize hVAO = _hVAO;

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

@property (nonatomic, assign, readwrite) GLuint bufferHandle;
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
        [_bufferAttributes retain];
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
    [_bufferAttributes release];
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
    glUniform1i(uniformLocation, textureUnitNum - GL_TEXTURE0);
    CHECK_GL_ERROR();
}

- (void) deactivateTexture {
    glBindTexture(GL_TEXTURE_2D, 0);
    CHECK_GL_ERROR();
}

@end




@interface NFRGeometry()
@property (nonatomic, retain, readwrite) NSMutableDictionary* textureDictionary;
@end


@implementation NFRGeometry

@synthesize vertexBuffer = _vertexBuffer;
@synthesize indexBuffer = _indexBuffer;
@synthesize surfaceModel = _surfaceModel;
@synthesize mode = _mode;
@synthesize modelMatrix = _modelMatrix;
@synthesize textureDictionary = _textureDictionary;

@synthesize subroutineName = _subroutineName;

- (NSMutableDictionary*) textureDictionary {
    if (_textureDictionary == nil) {
        _textureDictionary = [[[NSMutableDictionary alloc] init] retain];
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
    NFRDataMap *diffuseMap = [self.surfaceModel map_Kd];

    NFRDataMapGL* mapGL = [[[NFRDataMapGL alloc] init] autorelease];
    [mapGL syncDataMap:diffuseMap];

    NSString* uniformName = @"diffuseTexture";

    // make sure that the textureDictionary will hold onto the mapGL reference
    [self.textureDictionary setObject:mapGL forKey:uniformName];
}

- (void)dealloc {
    [_textureDictionary release];
    [super dealloc];
}

@end
