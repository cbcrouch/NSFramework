//
//  NFRenderer.m
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import "NFRenderer.h"
#import "NFRUtils.h"

//
// TODO: these headers and modules shouldn't be used in the renderer and are
//       only being used temporarily
//
#import "NFAssetLoader.h"


//
// TODO: find out who is including gl.h into the project (might be the display link...), one way around all this
//       might be to skip the provided OpenGL header file and use a custom loader
//

// NOTE: because both gl.h and gl3.h are included will get symbols for deprecated GL functions
//       and they should absolutely not be used
#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>

#import <GLKit/GLKit.h>


#pragma mark - NSGLRenderer Interface
@interface NFRenderer()
{
    //
    // TODO: need to replace these with properties as they should always be used in place
    //       of "naked" instance variables according to ObjC conventions
    //

    NFAssetData *m_pAsset;
    NFAssetData *m_axisData;
    NFAssetData *m_gridData;
    NFAssetData *m_planeData;

    GLuint m_hProgram;
    GLint m_modelLoc;

    GLsizei m_viewportWidth;
    GLsizei m_viewportHeight;

    GLuint m_normTexFuncIdx;
    GLuint m_expTexFuncIdx;

    GLuint m_hUBO;
}

- (void) loadShaders;

- (void) updateUboWithViewVolume:(NFViewVolume *)viewVolume;

@end

#pragma mark - NSGLRenderer Implementation
@implementation NFRenderer

- (instancetype) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    NSLog(@"GL_RENDERER:  %s", glGetString(GL_RENDERER));
    NSLog(@"GL_VENDOR:    %s", glGetString(GL_VENDOR));
    NSLog(@"GL_VERSION:   %s", glGetString(GL_VERSION));
    NSLog(@"GLSL_VERSION: %s", glGetString(GL_SHADING_LANGUAGE_VERSION));


    //
    // TODO: ideally should be able to init the renderer without requiring the viewport size
    //       and rely on the resizeToRect method for setting the viewport size (if that is not
    //       possible than should at least use a constant as the default/starting viewport size)
    //
    m_viewportWidth = 1280;
    m_viewportHeight = 720;


    [self loadShaders];

    m_normTexFuncIdx = glGetSubroutineIndex(m_hProgram, GL_FRAGMENT_SHADER, "NormalizedTexexlFetch");
    m_expTexFuncIdx = glGetSubroutineIndex(m_hProgram, GL_FRAGMENT_SHADER, "ExplicitTexelFetch");

    NSString *fileNamePath;

    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/cube/cube.obj";
    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/cube/cube-mod.obj";
    fileNamePath = @"/Users/cayce/Developer/NSGL/Models/leftsphere/leftsphere.obj";

    //
    // TODO: calculate normals for the teapot so that it can be lit, and import RGB based textures
    //
    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/teapot/teapot.obj";

    //
    // TODO: the following models have no textures applied to them (the suzanne model also has no normals) and
    //       should have a lighting model applied to them in order to verify they are being correctly imported
    //
    //       also the buddha and dragon models do not get drawn correctly, it looks like they might have a
    //       different primitive mode
    //
    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/suzanne.obj";
    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/buddha.obj";
    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/dragon.obj";


    //
    // TODO: need to organize the NFAssetData objects into a display set and/or PVS
    //

    m_pAsset = [NFAssetLoader allocAssetDataOfType:kWavefrontObj withArgs:fileNamePath, nil];
    [m_pAsset createVertexStateWithProgram:m_hProgram];
    [m_pAsset loadResourcesGL];


    m_axisData = [NFAssetLoader allocAssetDataOfType:kAxisWireframe withArgs:nil];
    [m_axisData createVertexStateWithProgram:m_hProgram];
    [m_axisData loadResourcesGL];


    m_gridData = [NFAssetLoader allocAssetDataOfType:kGridWireframe withArgs:nil];
    [m_gridData createVertexStateWithProgram:m_hProgram];
    [m_gridData loadResourcesGL];


    m_planeData = [NFAssetLoader allocAssetDataOfType:kSolidPlane withArgs:nil];
    [m_planeData createVertexStateWithProgram:m_hProgram];
    [m_planeData loadResourcesGL];


    // setup OpenGL state that will never change
    //glClearColor(1.0f, 0.0f, 1.0f, 1.0f); // hot pink for hot debugging
    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    CHECK_GL_ERROR();

    return self;
}

- (void) dealloc {
    //
    // TODO: need to properly clean up after finishing refactoring
    //

    [m_pAsset release];
    [m_axisData release];
    [m_gridData release];
    [m_planeData release];

    // NOTE: helper method will take care of cleaning up all shaders attached to program
    [NFRUtils destroyProgramWithHandle:m_hProgram];

    [super dealloc];
}

- (void) updateFrameWithTime:(const CVTimeStamp*)outputTime withViewVolume:(NFViewVolume *)viewVolume {
    //static float secs = 0.0; // elapsed time
    static uint64_t prevVideoTime = 0;

    //
    // TODO: if debug check time stamp flags against kCVTimeStampVideoHostTimeValid
    //

    //NSLog(@"update period per second: %lld", outputTime->videoTimeScale / outputTime->videoRefreshPeriod);

    // update rate 59 hertz
    // 0.016699 seconds
    // 16.600 ms

    if (prevVideoTime != 0) {
        //secs += (outputTime->videoTime - prevVideoTime) / (float) outputTime->videoTimeScale;
        //NSLog(@"secs: %f", secs);

        // step is a floating point measure of time (1.0 == one second)
        float step = (outputTime->videoTime - prevVideoTime) / (float) outputTime->videoTimeScale;
        [m_pAsset stepTransforms:step];
    }

    prevVideoTime = outputTime->videoTime;

    if (viewVolume.dirty) {
        [self updateUboWithViewVolume:viewVolume];
        viewVolume.dirty = NO;
    }
}

//
// TODO: renderFrame should take a scene/PVS, and pipeline object as params
//       (viewport will be set/bound ahead of time for the renderer instance)
//
- (void) renderFrame {

    //
    // TODO: when in DEBUG mode check to verify that the frame buffer is valid, under some
    //       circumstances when first starting up the application the renderer can attempt
    //       to draw into a frame buffer before it is ready
    //

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    glUseProgram(m_hProgram);

    //
    // TODO: need to decouple the drawing methods from the NFAssetData class
    //       (this will require at least stubbing out the entity control system)
    //

    glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &m_normTexFuncIdx);
    [m_pAsset drawWithProgram:m_hProgram withModelUniform:m_modelLoc];

    glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &m_expTexFuncIdx);
    [m_axisData drawWithProgram:m_hProgram withModelUniform:m_modelLoc];

    //[m_gridData drawWithProgram:m_hProgram withModelUniform:m_modelLoc];

    //[m_planeData drawWithProgram:m_hProgram withModelUniform:m_modelLoc];

    glUseProgram(0);
    CHECK_GL_ERROR();
}

- (void) resizeToRect:(CGRect)rect {
    GLsizei width = (GLsizei)CGRectGetWidth(rect);
    GLsizei height = (GLsizei)CGRectGetHeight(rect);

    if ((m_viewportWidth != width) || (m_viewportHeight != height)) {
        m_viewportWidth = width;
        m_viewportHeight = height;
        glViewport((GLint)0, (GLint)0, m_viewportWidth, m_viewportHeight);
    }
}

- (void) loadShaders {
    NSString *vertSource = [NFRUtils loadShaderSourceWithName:@"OpenGLModel" ofType:kVertexShader];
    NSString *fragSource = [NFRUtils loadShaderSourceWithName:@"OpenGLModel" ofType:kFragmentShader];
    m_hProgram = [NFRUtils createProgramWithVertexSource:vertSource withFragmentSource:fragSource];
    NSAssert(m_hProgram != 0, @"Failed to create GL shader program");



    // load the WavefrontModel shader program to ensure that it compiles
    vertSource = [NFRUtils loadShaderSourceWithName:@"WavefrontModel" ofType:kVertexShader];
    fragSource = [NFRUtils loadShaderSourceWithName:@"WavefrontModel" ofType:kFragmentShader];
    GLuint tempProgram = [NFRUtils createProgramWithVertexSource:vertSource withFragmentSource:fragSource];
    NSAssert(tempProgram != 0, @"Failed to create GL shader program");



    // NOTE: helper method will take care of cleaning up all shaders attached to program
    [NFRUtils destroyProgramWithHandle:tempProgram];



    // setup uniform for model matrix
    m_modelLoc = glGetUniformLocation(m_hProgram, (const GLchar *)"model\0");
    NSAssert(m_modelLoc != -1, @"Failed to get MVP uniform location");

    // uniform buffer for view and projection matrix
    m_hUBO = [NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:m_hProgram];
}

//
// TODO: explicitly define a coordinate system (left or right-handed) though should note that the
//       Wavefront obj file format specifies vertices in a right-handed coordinate system
//
- (void) updateUboWithViewVolume:(NFViewVolume *)viewVolume {
    //
    // TODO: while not yet implemented should consider using some additional utility
    //       methods for simplfying UBOs assuming they can be made worth while
    //
    //+ (void) setUniformBuffer:(GLuint)hUBO withData:(NSArray *)dataArray inProgrm:(GLuint)handle;


    GLsizeiptr matrixSize = (GLsizeiptr)(16 * sizeof(float));
    GLintptr offset = (GLintptr)matrixSize;

    glBindBuffer(GL_UNIFORM_BUFFER, m_hUBO);

    // will allocate buffer's internal storage
    glBufferData(GL_UNIFORM_BUFFER, 2 * matrixSize, NULL, GL_STATIC_READ);

    // transfer view and projection matrix data to uniform buffer
    glBufferSubData(GL_UNIFORM_BUFFER, (GLintptr)0, matrixSize, [viewVolume view].m);
    glBufferSubData(GL_UNIFORM_BUFFER, offset, matrixSize, [viewVolume projection].m);

    glBindBuffer(GL_UNIFORM_BUFFER, 0);
    CHECK_GL_ERROR();
}

@end
