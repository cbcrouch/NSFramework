//
//  NFRUtils.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRUtils.h"

// NOTE: because both gl.h and gl3.h are included will get symbols for deprecated GL functions
//       and they should absolutely not be used
#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>

#ifdef DEBUG
#define VALIDATE_PROGRAM(PROGRAM_HANDLE) [NSGLRenderer checkShader:PROGRAM_HANDLE ofType:kProgram againstStatus:kValidateStatus]
#else
#define VALIDATE_PROGRAM(PROGRAM_HANDLE) // no-op when building release version
#endif

typedef NS_ENUM(NSUInteger, SHADER_STATUS) {
    kCompileStatus,
    kLinkStatus,
    kValidateStatus
};


// uniform buffer binding point will need to default to 1 in renderer init (will need a class method for initializing OpenGL state)
//static GLuint g_bindingPoint = 1; // must be smaller than GL_MAX_UNIFORM_BUFFER_BINDINGS


@interface NFRUtils()
+ (NSString *) loadShaderSourceWithName:(NSString *)shaderName ofType:(SHADER_TYPE)type;
+ (void) checkShader:(const GLuint)handle ofType:(SHADER_TYPE)type againstStatus:(SHADER_STATUS)status;
@end

@implementation NFRUtils

+ (GLuint) createProgramWithVertexSource:(NSString *)vertexSource withFragmentSource:(NSString *)fragmentSource {
    GLuint hProgram = 0;
    GLuint hVertexShader = 0;
    GLuint hFragShader = 0;
    const GLchar *vs_source = [vertexSource cStringUsingEncoding:NSASCIIStringEncoding];
    const GLchar *fs_source = [fragmentSource cStringUsingEncoding:NSASCIIStringEncoding];

    // create vertex shader
    hVertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(hVertexShader, 1, &vs_source, 0);
    glCompileShader(hVertexShader);
#ifdef DEBUG
    [NFRUtils checkShader:hVertexShader ofType:kVertexShader againstStatus:kCompileStatus];
    CHECK_GL_ERROR();
#endif

    // create fragment shader
    hFragShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(hFragShader, 1, &fs_source, 0);
    glCompileShader(hFragShader);
#ifdef DEBUG
    [NFRUtils checkShader:hFragShader ofType:kFragmentShader againstStatus:kCompileStatus];
    CHECK_GL_ERROR();
#endif

    // create shader program
    hProgram = glCreateProgram();
    glAttachShader(hProgram, hVertexShader);
    glAttachShader(hProgram, hFragShader);
    glLinkProgram(hProgram);
#ifdef DEBUG
    [NFRUtils checkShader:hProgram ofType:kProgram againstStatus:kLinkStatus];
    // NOTE: should not be performing validation check here, validation step is a debug check typically performed
    //       prior to a draw attempt with a given shader program since the glValidateProgram call checks whether
    //       the program can execute against the given OpenGL state at the time of the call (it would be meaningless
    //       to perform the check when initializing the program since the OpenGL state on init is not typically
    //       configured to be making draw calls)
    CHECK_GL_ERROR();
#endif

    return hProgram;
}

+ (GLuint) createProgram:(NSString *)programName {
    GLuint hProgram = 0;
    GLuint hVertexShader = 0;
    GLuint hFragShader = 0;
    NSString* vertexSource = [NFRUtils loadShaderSourceWithName:programName ofType:kVertexShader];
    NSString* fragmentSource = [NFRUtils loadShaderSourceWithName:programName ofType:kFragmentShader];
    const GLchar *vs_source = [vertexSource cStringUsingEncoding:NSASCIIStringEncoding];
    const GLchar *fs_source = [fragmentSource cStringUsingEncoding:NSASCIIStringEncoding];

    // create vertex shader
    hVertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(hVertexShader, 1, &vs_source, 0);
    glCompileShader(hVertexShader);
#ifdef DEBUG
    [NFRUtils checkShader:hVertexShader ofType:kVertexShader againstStatus:kCompileStatus];
    CHECK_GL_ERROR();
#endif

    // create fragment shader
    hFragShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(hFragShader, 1, &fs_source, 0);
    glCompileShader(hFragShader);
#ifdef DEBUG
    [NFRUtils checkShader:hFragShader ofType:kFragmentShader againstStatus:kCompileStatus];
    CHECK_GL_ERROR();
#endif

    // create shader program
    hProgram = glCreateProgram();
    glAttachShader(hProgram, hVertexShader);
    glAttachShader(hProgram, hFragShader);
    glLinkProgram(hProgram);
#ifdef DEBUG
    [NFRUtils checkShader:hProgram ofType:kProgram againstStatus:kLinkStatus];
    // NOTE: should not be performing validation check here, validation step is a debug check typically performed
    //       prior to a draw attempt with a given shader program since the glValidateProgram call checks whether
    //       the program can execute against the given OpenGL state at the time of the call (it would be meaningless
    //       to perform the check when initializing the program since the OpenGL state on init is not typically
    //       configured to be making draw calls)
    CHECK_GL_ERROR();
#endif

    return hProgram;
}

+ (void) destroyProgramWithHandle:(GLuint)handle {
    NSAssert(handle != 0, @"Error attempting to destroy non-valid program handle");

    // get number of attached shaders and allocate memory to hold handles for them
    GLsizei shaderCount;
    glGetProgramiv(handle, GL_ATTACHED_SHADERS, &shaderCount);

    GLuint *pShaders = (GLuint *)malloc(shaderCount * sizeof(GLuint));
    NSAssert(pShaders != NULL, @"Failed malloc for shader handles");

    // get the handles of the attached shaders to the program
    glGetAttachedShaders(handle, shaderCount, &shaderCount, pShaders);

    // delete the shaders attached to the program
    GLsizei shaderNum;
    GLuint *pItr;
    for (shaderNum = 0, pItr = pShaders; shaderNum < shaderCount; ++shaderNum, ++pItr) {
        if (pItr != NULL) {
            glDeleteShader(*pItr);
        }
    }

    // free memory allocated for shader handles
    if (pShaders != NULL) {
        free(pShaders);
    }

    // delete the program
    glDeleteProgram(handle);
    glUseProgram(0);
}

+ (void) destroyVaoWithHandle:(GLuint)hVAO {
    GLuint hBuffer;

    // bind the VAO so we can get data from it
    glBindVertexArray(hVAO);

    //
    // TODO: get the MAX number of possible attributes per VAO and loop on that
    //       instead of using a magic number i.e. 16
    //

    // for every possible attribute set in the VAO
    for (GLuint i=0; i < 16; ++i) {
        // get the VBO set for that attribute
        glGetVertexAttribiv(i, GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, (GLint *)&hBuffer);

        // delete VBO if valid
        if (hBuffer) {
            glDeleteBuffers(1, &hBuffer);
        }
    }

    // get index buffer set for the VAO
    glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, (GLint *)&hBuffer);

    // delete index buffer if valid
    if (hBuffer) {
        glDeleteBuffers(1, &hBuffer);
    }

    // delete the VAO
    glDeleteVertexArrays(1, &hVAO);
    CHECK_GL_ERROR();
}

+ (NSString *) loadShaderSourceWithName:(NSString *)shaderName ofType:(SHADER_TYPE)type; {
    NSString *fileExt = nil;
    NSString *filePathName = nil;

    switch (type) {
        case kVertexShader: fileExt = @"vsh"; break;
        case kFragmentShader: fileExt = @"fsh"; break;
        default:
            NSAssert(YES, @"Error: load shader source called for an unknown shader type");
            break;
    }

    NSAssert(fileExt != nil, @"Failed to identify shader file extension type");

    //
    // TODO: use [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&nsErr]
    //

    filePathName = [[NSBundle mainBundle] pathForResource:shaderName ofType:fileExt];
    NSAssert(filePathName != nil, @"Failed to find path to %@.%@", shaderName, fileExt);

    NSFileHandle *shaderFileHandle;
    shaderFileHandle = [NSFileHandle fileHandleForReadingAtPath:filePathName];
    NSAssert(shaderFileHandle != nil, @"Failed to open %@.%@", shaderName, fileExt);

    NSData *shaderData = [shaderFileHandle readDataToEndOfFile];
    NSAssert(shaderData != nil, @"Failed to read NSFileHandle");

    // NOTE: this works with NON-NULL terminated data
    NSString *shaderSource = [[[NSString alloc] initWithData:shaderData encoding:NSUTF8StringEncoding] autorelease];
    NSAssert(shaderSource != nil, @"Failed to convert NSData to an NSString");

    // at this point shaderSource should have a copy of the NSData from the file read and the file can be closed
    [shaderFileHandle closeFile];

    return shaderSource;
}

+ (void) checkGLError:(const char *)file line:(const int)line function:(const char *)function {
    GLenum glErr;
    while ((glErr = glGetError()) != GL_NO_ERROR) {
        switch (glErr) {
            case GL_INVALID_ENUM: NSLog(@"%s %d %s: GL_INVALID_ENUM", file, line, function); break;
            case GL_INVALID_VALUE: NSLog(@"%s %d %s: GL_INVALID_VALUE", file, line, function); break;
            case GL_INVALID_OPERATION: NSLog(@"%s %d %s: GL_INVALID_OPERATION", file, line, function); break;
            case GL_INVALID_FRAMEBUFFER_OPERATION: NSLog(@"%s %d %s: GL_INVALID_FRAMEBUFFER_OPERATION", file, line, function); break;
            case GL_OUT_OF_MEMORY: NSLog(@"%s %d %s: GL_OUT_OF_MEMORY", file, line, function); break;
            default: NSLog(@"%s %d %s UNKNOWN GL ERROR", file, line, function); break;
        }
    };
}

+ (void) checkShader:(const GLuint)handle ofType:(SHADER_TYPE)type againstStatus:(SHADER_STATUS)status {
    GLchar *pInfoLog;
    GLint maxLength;
    GLenum kName;
    GLint didComplete = GL_FALSE;
    NSString *statusString;

    switch (status) {
        case kCompileStatus:
            kName = GL_COMPILE_STATUS;
            statusString = @"GL_COMPILE_STATUS";
            break;

        case kLinkStatus:
            kName = GL_LINK_STATUS;
            statusString = @"GL_LINK_STATUS";
            break;

        case kValidateStatus:
            kName = GL_VALIDATE_STATUS;
            statusString = @"GL_VALIDATE_STATUS";
            glValidateProgram(handle);
            break;

        default:
            NSAssert(NO, @"ERROR: check shader received unknown status to check shader/program against");
            break;
    }

    if (type != kProgram) {
        glGetShaderiv(handle, kName, &didComplete);
    }
    else {
        glGetProgramiv(handle, kName, &didComplete);
    }

    if (didComplete == GL_FALSE) {
        NSLog(@"NSGLRenderer: shader failed check against %@", statusString);

        if (type != kProgram) {
            glGetShaderiv(handle, GL_INFO_LOG_LENGTH, &maxLength);
        }
        else {
            glGetProgramiv(handle, GL_INFO_LOG_LENGTH, &maxLength);
        }

        pInfoLog = (GLchar *)malloc(maxLength);
        if (pInfoLog == NULL) {
            NSLog(@"NSGLRenderer: couldn't allocate memory to retrieve log");
        }
        else {
            if (type != kProgram) {
                glGetShaderInfoLog(handle, maxLength, &maxLength, pInfoLog);
            }
            else {
                glGetProgramInfoLog(handle, maxLength, &maxLength, pInfoLog);
            }

            // NOTE: string is NULL terminated i.e. if it is empty it still has a length of 1
            if (maxLength > 1) {
                NSLog(@"NSGLRenderer log: %s", pInfoLog);
            }
            free(pInfoLog);
        }
        
        return;
    }
}

+ (GLuint) createUniformBufferNamed:(NSString *)bufferName inProgrm:(GLuint)handle {
    // NOTE: in order for the uniform block index to be found it must be actively used inside the
    //       shader, if it isn't used or is only used in an unreachable portion of code it will
    //       be removed by the compiler and attempts to get the block index will return as invalid

    GLuint blockIndex = glGetUniformBlockIndex(handle, (const GLchar *)[bufferName cStringUsingEncoding:NSASCIIStringEncoding]);
    NSAssert(blockIndex != GL_INVALID_INDEX, @"Failed to get uniform block index");

    GLint blockSize;
    GLint numBlocks;
    glGetActiveUniformBlockiv(handle, blockIndex, GL_UNIFORM_BLOCK_DATA_SIZE, &blockSize);
    glGetActiveUniformBlockiv(handle, blockIndex, GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS, &numBlocks);



    //
    // TODO: use a static var to start the bindPoint and then increment (if binding points are used for other types in the context will need to handle differently)
    //       ideally will need to better manage as shaders are create/deleted possibly freeing up binding points in the context
    //
    static GLuint bindingPoint = 1;
    NSAssert(bindingPoint < GL_MAX_UNIFORM_BUFFER_BINDINGS, @"Error: binding point >= to GL_MAX_UNIFORM_BUFFER_BINDINGS");



    GLuint hUBO = 0;

    // allocate buffer's internal storage
    glGenBuffers(1, &hUBO);
    glBindBuffer(GL_UNIFORM_BUFFER, hUBO);
    glBufferData(GL_UNIFORM_BUFFER, blockSize, NULL, GL_STATIC_READ);
    glBindBuffer(GL_UNIFORM_BUFFER, 0);


    //
    // TODO: should be using layout qualifiers with glUniformBlockBinding and the use glBindBufferRange
    //       or glBindBufferBase to change the actual buffer
    //

    // bind uniform block to a binding point in the active context
    glUniformBlockBinding(handle, blockIndex, bindingPoint);

    // bind the data buffer to the index of the block using one of the uniform binding points in the context
    glBindBufferBase(GL_UNIFORM_BUFFER, bindingPoint, hUBO);

    //
    // TODO: use bind buffer range for shaders using more than one uniform buffer (assuming that this is
    //       the correct usage of glBindBufferRange)
    //

    //
    // TODO: could potentially use the code below for some automated uniform buffer utility i.e. to
    //       query the offsets or to perform some error checking / diagnostics
    //
/*
    GLint active;
    glGetActiveUniformBlockiv(m_hProgram, mvpIndex, GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS, &active);
    NSLog(@"number of active uniforms in uniform buffer: %d", active);

    GLuint *indices = (GLuint *)malloc(active * sizeof(GLuint));
    const GLchar *cnames[2];
    cnames[0] = "view";
    cnames[1] = "projection";

    glGetUniformIndices(m_hProgram, active, cnames, indices);

    GLint *matStride = (GLint *)malloc(active * sizeof(GLint));
    glGetActiveUniformsiv(m_hProgram, active, indices, GL_UNIFORM_MATRIX_STRIDE, matStride);
    for (int i=0; i<2; ++i) {
        NSLog(@"matStride: %d", matStride[i]);
    }

    free(indices);
    free(matStride);
*/


    ++bindingPoint;
    
    CHECK_GL_ERROR();
    return hUBO;
}

+ (void) destroyUniformBufferHandle:(GLuint)handle {
    //
    // TODO: clean up uniform buffer
    //
}

+ (void) setUniformBuffer:(GLuint)hUBO withData:(NSArray *)dataArray inProgrm:(GLuint)handle {
    //GLint blockSize;
    //GLint numBlocks;
    //glGetActiveUniformBlockiv(handle, blockIndex, GL_UNIFORM_BLOCK_DATA_SIZE, &blockSize);
    //glGetActiveUniformBlockiv(handle, blockIndex, GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS, &numBlocks);

    //GLsizeiptr elementSize = (GLsizeiptr)(blockSize / numBlocks);
    //GLintptr offset = (GLintptr)elementSize;

    //
    //
    //
    
/*
    // TODO: loop through numBlocks and set buffer sub data from an array in set UBO data function

    // transfer view and projection matrix data to uniform buffer
    glBufferSubData(GL_UNIFORM_BUFFER, (GLintptr)0, elementSize, m_viewVolume.view.m);
    glBufferSubData(GL_UNIFORM_BUFFER, offset, elementSize, m_viewVolume.projection.m);
*/
}

//
// TODO: cleanup and add the displaySubroutines function to NFRUtils
//
/*
+ (void) displaySubroutines:(GLuint)hProgram {
    int len, numCompS;
    int maxSub, maxSubU, countActiveSU;
    char name[256];

    glGetIntegerv(GL_MAX_SUBROUTINES, &maxSub);
    glGetIntegerv(GL_MAX_SUBROUTINE_UNIFORM_LOCATIONS, &maxSubU);
    printf("Max Subroutines: %d  Max Subroutine Uniforms: %d\n", maxSub, maxSubU);

    glGetProgramStageiv(hProgram, GL_FRAGMENT_SHADER, GL_ACTIVE_SUBROUTINE_UNIFORMS, &countActiveSU);

    for (int i=0; i<countActiveSU; ++i) {
        glGetActiveSubroutineUniformName(hProgram, GL_FRAGMENT_SHADER, i, 256, &len, name);

        printf("Suroutine Uniform: %d name: %s\n", i,name);
        glGetActiveSubroutineUniformiv(hProgram, GL_FRAGMENT_SHADER, i, GL_NUM_COMPATIBLE_SUBROUTINES, &numCompS);

        int *s = (int *)malloc(sizeof(int) * numCompS);
        glGetActiveSubroutineUniformiv(hProgram, GL_FRAGMENT_SHADER, i, GL_COMPATIBLE_SUBROUTINES, s);
        printf("Compatible Subroutines:\n");

        for (int j=0; j < numCompS; ++j) {
            glGetActiveSubroutineName(hProgram, GL_FRAGMENT_SHADER, s[j], 256, &len, name);
            printf("\t%d - %s\n", s[j],name);
        }
        printf("\n");
        free(s);
    }
}
*/

@end
