//
//  NFRenderer.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRenderer.h"
#import "NFRUtils.h"

//
// TODO: move NFAssetLoader module test code into NFSimulation module once it has been stubbed out
//
#import "NFAssetLoader.h"


// NOTE: because both gl.h and gl3.h are included will get symbols for deprecated GL functions
//       and they should absolutely not be used
#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>

#import <GLKit/GLKit.h>



@interface NFViewport : NSObject
@property (nonatomic, assign) NFViewportId uniqueId;
//
// TODO: define and use an NFRect style type but with GLsizei params to avoid
//       numerous casts to-and-from floats/ints
//
@property (nonatomic, assign) CGRect viewRect;
@end

@implementation NFViewport
@end



#pragma mark - NSGLRenderer Interface
@interface NFRenderer()
{
    NFAssetData *m_pAsset;
    NFAssetData *m_axisData;
    NFAssetData *m_gridData;
    NFAssetData *m_planeData;

    NFAssetData *m_solidSphere;

    //
    // TODO: this information should be stored in some kind of NFRendererProgram object
    //       or an NFPipeline object (need to determine the easiest and simplist way to encapsulate shaders)
    //
    GLint m_modelLoc;
    GLuint m_normTexFuncIdx;
    GLuint m_expTexFuncIdx;
    GLuint m_hUBO;
    GLuint m_hProgram;
}

@property (nonatomic, retain) NSArray* viewports;

- (void) loadShaders;
- (void) updateUboWithViewMatrix:(GLKMatrix4)viewMatrix withProjection:(GLKMatrix4)projection;

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

    NFViewport* viewportArray[MAX_NUM_VIEWPORTS];
    for (int i=0; i<MAX_NUM_VIEWPORTS; ++i) {
        viewportArray[i] = [[[NFViewport alloc] init] autorelease];
        viewportArray[i].uniqueId = -1;
        viewportArray[i].viewRect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    }

    viewportArray[0].uniqueId = 1;
    viewportArray[0].viewRect = CGRectMake(0.0f, 0.0f,
        (CGFloat)DEFAULT_VIEWPORT_WIDTH, (CGFloat)DEFAULT_VIEWPORT_HEIGHT);

    [self setViewports:[NSArray arrayWithObjects:viewportArray count:MAX_NUM_VIEWPORTS]];
    [self loadShaders];

    NSString *fileNamePath;

    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/cube/cube.obj";
    fileNamePath = @"/Users/cayce/Developer/NSGL/Models/cube/cube-mod.obj";
    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/leftsphere/leftsphere.obj";

    //
    // TODO: teapot contains vertices and texture coordinates (no normals), does not use objects or groups,
    //       and has two different geometries defined separated by listing i.e. first object has v,vt,f and
    //       then the second object lists its v,vt,f components
    //
    //       also need to figure out why the default texture is not getting applied
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


    m_pAsset = [NFAssetLoader allocAssetDataOfType:kWavefrontObj withArgs:fileNamePath, nil];
    [m_pAsset createVertexStateWithProgram:m_hProgram];
    [m_pAsset loadResourcesGL];

    //m_pAsset.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 1.0f, 0.0f);

    //[m_pAsset applyOriginCenterMatrix];

    //[m_pAsset applyUnitScalarMatrix]; // use for teapot


    m_axisData = [NFAssetLoader allocAssetDataOfType:kAxisWireframe withArgs:nil];
    [m_axisData createVertexStateWithProgram:m_hProgram];
    [m_axisData loadResourcesGL];


    m_gridData = [NFAssetLoader allocAssetDataOfType:kGridWireframe withArgs:nil];
    [m_gridData createVertexStateWithProgram:m_hProgram];
    [m_gridData loadResourcesGL];


    m_planeData = [NFAssetLoader allocAssetDataOfType:kSolidPlane withArgs:nil];
    [m_planeData createVertexStateWithProgram:m_hProgram];
    [m_planeData loadResourcesGL];


    m_solidSphere = [NFAssetLoader allocAssetDataOfType:kSolidUVSphere withArgs:nil];
    [m_solidSphere createVertexStateWithProgram:m_hProgram];
    [m_solidSphere loadResourcesGL];

    m_solidSphere.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 2.0f, 1.0f, 0.0f);
    m_solidSphere.modelMatrix = GLKMatrix4Scale(m_solidSphere.modelMatrix, 0.065f, 0.065f, 0.065f);

    _stepTransforms = NO;


    // setup OpenGL state that will never change
    //glClearColor(1.0f, 0.0f, 1.0f, 1.0f); // hot pink for debugging
    glClearColor(0.30f, 0.30f, 0.30f, 1.0f);

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
    [m_solidSphere release];

    // NOTE: helper method will take care of cleaning up all shaders attached to program
    [NFRUtils destroyProgramWithHandle:m_hProgram];

    [super dealloc];
}

- (void) updateFrameWithTime:(float)secsElapsed withViewMatrix:(GLKMatrix4)viewMatrix
              withProjection:(GLKMatrix4)projection {
    if (self.stepTransforms) {
        [m_pAsset stepTransforms:secsElapsed];
        //[m_pAsset stepTransforms:0.0f];

        [m_solidSphere stepTransforms:secsElapsed];
    }

    //
    // TODO: need to either send in a dirty flag or cache the values and compare so that the
    //       renderer is not updating the UBO every frame
    //
    [self updateUboWithViewMatrix:viewMatrix withProjection:projection];
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

    //[m_gridData drawWithProgram:m_hProgram withModelUniform:m_modelLoc];

    //[m_planeData drawWithProgram:m_hProgram withModelUniform:m_modelLoc];

    [m_solidSphere drawWithProgram:m_hProgram withModelUniform:m_modelLoc];


    glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &m_expTexFuncIdx);
    [m_axisData drawWithProgram:m_hProgram withModelUniform:m_modelLoc];

    glUseProgram(0);
    CHECK_GL_ERROR();
}

- (void) resizeToRect:(CGRect)rect {
    NFViewport *viewport = [self.viewports objectAtIndex:0];

    if (viewport.viewRect.size.width != CGRectGetWidth(rect) ||
        viewport.viewRect.size.height != CGRectGetHeight(rect)) {
        viewport.viewRect = rect;
        glViewport((GLint)0, (GLint)0, (GLsizei)CGRectGetWidth(rect), (GLsizei)CGRectGetHeight(rect));
    }
}

- (void) loadShaders {

    //
    // TODO: load DefaultModel shader source
    //


    //
    // TODO: need a create program helper method that just takes one string and then loads all
    //       shader source files of that name
    //

    NSString *vertSource = [NFRUtils loadShaderSourceWithName:@"OpenGLModel" ofType:kVertexShader];
    NSString *fragSource = [NFRUtils loadShaderSourceWithName:@"OpenGLModel" ofType:kFragmentShader];

    m_hProgram = [NFRUtils createProgramWithVertexSource:vertSource withFragmentSource:fragSource];
    NSAssert(m_hProgram != 0, @"Failed to create GL shader program");

    m_normTexFuncIdx = glGetSubroutineIndex(m_hProgram, GL_FRAGMENT_SHADER, "NormalizedTexexlFetch");
    m_expTexFuncIdx = glGetSubroutineIndex(m_hProgram, GL_FRAGMENT_SHADER, "ExplicitTexelFetch");

    // setup uniform for model matrix
    m_modelLoc = glGetUniformLocation(m_hProgram, (const GLchar *)"model\0");
    NSAssert(m_modelLoc != -1, @"Failed to get MVP uniform location");

    // uniform buffer for view and projection matrix
    m_hUBO = [NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:m_hProgram];



    // load the WavefrontModel shader program to ensure that it compiles
    vertSource = [NFRUtils loadShaderSourceWithName:@"WavefrontModel" ofType:kVertexShader];
    fragSource = [NFRUtils loadShaderSourceWithName:@"WavefrontModel" ofType:kFragmentShader];
    GLuint tempProgram = [NFRUtils createProgramWithVertexSource:vertSource withFragmentSource:fragSource];
    NSAssert(tempProgram != 0, @"Failed to create GL shader program");

    // NOTE: helper method will take care of cleaning up all shaders attached to program
    [NFRUtils destroyProgramWithHandle:tempProgram];
}

//
// TODO: explicitly define a coordinate system (left or right-handed) though should note that the
//       Wavefront obj file format specifies vertices in a right-handed coordinate system
//
- (void) updateUboWithViewMatrix:(GLKMatrix4)viewMatrix withProjection:(GLKMatrix4)projection {
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
    glBufferSubData(GL_UNIFORM_BUFFER, (GLintptr)0, matrixSize, viewMatrix.m);
    glBufferSubData(GL_UNIFORM_BUFFER, offset, matrixSize, projection.m);

    glBindBuffer(GL_UNIFORM_BUFFER, 0);
    CHECK_GL_ERROR();
}

@end
