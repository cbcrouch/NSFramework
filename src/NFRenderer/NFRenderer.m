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


typedef struct materialLocs_t {
    GLint matAmbientLoc;
    GLint matDiffuseLoc;
    GLint matSpecularLoc;
    GLint matShineLoc;
} materialLocs_t;

typedef struct lightLocs_t {
    GLint lightAmbientLoc;
    GLint lightDiffuseLoc;
    GLint lightSpecularLoc;
    GLint lightPositionLoc;
} lightLocs_t;

typedef struct phongModel_t {
    // vertex shader inputs
    GLint modelLoc;
    GLuint hUBO;

    // fragment shader inputs
    materialLocs_t matLocs;
    lightLocs_t lightLocs;
    GLint viewPositionLoc;
    GLuint lightSubroutine;
    GLuint phongSubroutine;

    // program handle
    GLuint hProgram;
} phongModel_t;

typedef struct debugProgram_t {

    //
    // TODO: store vertex format description in the shader program object so that can verify
    //       a vertex buffer will work with a given shader
    //

    // vertex shader inputs
    GLint modelLoc;
    GLuint hUBO;

    // fragment shader inputs

    // program handle
    GLuint hProgram;
} debugProgram_t;



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

    phongModel_t m_phongModel;
    debugProgram_t m_debugProgram;
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
    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/cube/cube-mod.obj";
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

    fileNamePath = @"/Users/cayce/Developer/NSGL/Models/suzanne.obj";

    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/buddha.obj";
    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/dragon.obj";

    GLuint hProgram = m_phongModel.hProgram;

    m_pAsset = [NFAssetLoader allocAssetDataOfType:kWavefrontObj withArgs:fileNamePath, nil];
    [m_pAsset createVertexStateWithProgram:hProgram];
    [m_pAsset loadResourcesGL];

    //m_pAsset.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 1.0f, 0.0f);

    //[m_pAsset applyOriginCenterMatrix];

    //[m_pAsset applyUnitScalarMatrix]; // use for teapot


    m_axisData = [NFAssetLoader allocAssetDataOfType:kAxisWireframe withArgs:nil];
    [m_axisData createVertexStateWithProgram:hProgram];
    [m_axisData loadResourcesGL];


    m_gridData = [NFAssetLoader allocAssetDataOfType:kGridWireframe withArgs:nil];
    [m_gridData createVertexStateWithProgram:hProgram];
    [m_gridData loadResourcesGL];


    m_planeData = [NFAssetLoader allocAssetDataOfType:kSolidPlane withArgs:nil];
    [m_planeData createVertexStateWithProgram:hProgram];
    [m_planeData loadResourcesGL];


    m_solidSphere = [NFAssetLoader allocAssetDataOfType:kSolidUVSphere withArgs:nil];
    [m_solidSphere createVertexStateWithProgram:hProgram];
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
    [NFRUtils destroyProgramWithHandle:m_phongModel.hProgram];
    [NFRUtils destroyProgramWithHandle:m_debugProgram.hProgram];

    [super dealloc];
}

- (void) updateFrameWithTime:(float)secsElapsed withViewPosition:(GLKVector3)viewPosition
              withViewMatrix:(GLKMatrix4)viewMatrix
              withProjection:(GLKMatrix4)projection {

    //
    // TODO: should not be use shader programs in the frame update, defer it until the draw call
    //
    glUseProgram(m_phongModel.hProgram);
    glUniform3f(m_phongModel.viewPositionLoc, viewPosition.x, viewPosition.y, viewPosition.z);
    glUseProgram(0);
    CHECK_GL_ERROR();

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
    glUseProgram(m_phongModel.hProgram);

    m_phongModel.lightSubroutine = glGetSubroutineIndex(m_phongModel.hProgram, GL_FRAGMENT_SHADER, "light_subroutine");
    NSAssert(m_phongModel.lightSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");

    m_phongModel.phongSubroutine = glGetSubroutineIndex(m_phongModel.hProgram, GL_FRAGMENT_SHADER, "phong_subroutine");
    NSAssert(m_phongModel.phongSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");

    // cube
    glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &(m_phongModel.phongSubroutine));
    [m_pAsset drawWithProgram:m_phongModel.hProgram withModelUniform:m_phongModel.modelLoc];

    // light
    glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &(m_phongModel.lightSubroutine));
    [m_solidSphere drawWithProgram:m_phongModel.hProgram withModelUniform:m_phongModel.modelLoc];



    //
    // TODO: draw axis guidelines
    //

    //
    // TODO: will need to create a vertex description object
    //

    glUseProgram(m_debugProgram.hProgram);



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
    // load default model
    m_phongModel.hProgram = [NFRUtils createProgram:@"DefaultModel"];
    NSAssert(m_phongModel.hProgram != 0, @"Failed to create GL shader program");

    m_phongModel.modelLoc = glGetUniformLocation(m_phongModel.hProgram, (const GLchar *)"model");
    NSAssert(m_phongModel.modelLoc != -1, @"failed to get MVP uniform location");

    // uniform buffer for view and projection matrix
    m_phongModel.hUBO = [NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:m_phongModel.hProgram];
    NSAssert(m_phongModel.hUBO != 0, @"failed to get uniform buffer handle");

    // material struct uniform locations
    m_phongModel.matLocs.matAmbientLoc = glGetUniformLocation(m_phongModel.hProgram, "material.ambient");
    NSAssert(m_phongModel.matLocs.matAmbientLoc != -1, @"failed to get uniform location");

    m_phongModel.matLocs.matDiffuseLoc = glGetUniformLocation(m_phongModel.hProgram, "material.diffuse");
    NSAssert(m_phongModel.matLocs.matDiffuseLoc != -1, @"failed to get uniform location");

    m_phongModel.matLocs.matSpecularLoc = glGetUniformLocation(m_phongModel.hProgram, "material.specular");
    NSAssert(m_phongModel.matLocs.matSpecularLoc != -1, @"failed to get uniform location");

    m_phongModel.matLocs.matShineLoc = glGetUniformLocation(m_phongModel.hProgram, "material.shininess");
    NSAssert(m_phongModel.matLocs.matShineLoc != -1, @"failed to get uniform location");

    // hardcoded material values (jade)
    glUseProgram(m_phongModel.hProgram);
    glUniform3f(m_phongModel.matLocs.matAmbientLoc, 0.135f, 0.2225f, 0.1575f);
    glUniform3f(m_phongModel.matLocs.matDiffuseLoc, 0.54f, 0.89f, 0.63f);
    glUniform3f(m_phongModel.matLocs.matSpecularLoc, 0.316228f, 0.316228f, 0.316228f);
    glUniform1f(m_phongModel.matLocs.matShineLoc, 128.0f * 0.1f);
    glUseProgram(0);

    // light struct uniform locations
    m_phongModel.lightLocs.lightAmbientLoc = glGetUniformLocation(m_phongModel.hProgram, "light.ambient");
    NSAssert(m_phongModel.lightLocs.lightAmbientLoc != -1, @"failed to get uniform location");

    m_phongModel.lightLocs.lightDiffuseLoc = glGetUniformLocation(m_phongModel.hProgram, "light.diffuse");
    NSAssert(m_phongModel.lightLocs.lightDiffuseLoc != -1, @"failed to get uniform location");

    m_phongModel.lightLocs.lightSpecularLoc = glGetUniformLocation(m_phongModel.hProgram, "light.specular");
    NSAssert(m_phongModel.lightLocs.lightSpecularLoc != -1, @"failed to get uniform location");

    m_phongModel.lightLocs.lightPositionLoc = glGetUniformLocation(m_phongModel.hProgram, "light.position");
    NSAssert(m_phongModel.lightLocs.lightPositionLoc != -1, @"failed to get uniform location");

    // hardcoded light values
    glUseProgram(m_phongModel.hProgram);
    glUniform3f(m_phongModel.lightLocs.lightAmbientLoc, 0.2f, 0.2f, 0.2f);
    glUniform3f(m_phongModel.lightLocs.lightDiffuseLoc, 0.5f, 0.5f, 0.5f);
    glUniform3f(m_phongModel.lightLocs.lightSpecularLoc, 1.0f, 1.0f, 1.0f);
    glUniform3f(m_phongModel.lightLocs.lightPositionLoc, 2.0f, 1.0f, 0.0f);
    glUseProgram(0);

    // view position uniform location
    m_phongModel.viewPositionLoc = glGetUniformLocation(m_phongModel.hProgram, "viewPos");
    NSAssert(m_phongModel.viewPositionLoc != -1, @"failed to get uniform location");

    // subroutine indices
    m_phongModel.lightSubroutine = glGetSubroutineIndex(m_phongModel.hProgram, GL_FRAGMENT_SHADER, "light_subroutine");
    NSAssert(m_phongModel.lightSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");

    m_phongModel.phongSubroutine = glGetSubroutineIndex(m_phongModel.hProgram, GL_FRAGMENT_SHADER, "phong_subroutine");
    NSAssert(m_phongModel.phongSubroutine != GL_INVALID_INDEX, @"failed to get subroutine index");

    CHECK_GL_ERROR();



    //
    // TODO: get the grid and axis lines drawing with the debug shader
    //

    m_debugProgram.hProgram = [NFRUtils createProgram:@"Debug"];
    NSAssert(m_debugProgram.hProgram != 0, @"Failed to create GL shader program");

    //normTexFuncIdx = glGetSubroutineIndex(m_hProgram, GL_FRAGMENT_SHADER, "NormalizedTexexlFetch");
    //expTexFuncIdx = glGetSubroutineIndex(m_hProgram, GL_FRAGMENT_SHADER, "ExplicitTexelFetch");

    // setup uniform for model matrix
    m_debugProgram.modelLoc = glGetUniformLocation(m_debugProgram.hProgram, (const GLchar *)"model");
    NSAssert(m_debugProgram.modelLoc != -1, @"Failed to get MVP uniform location");

    // uniform buffer for view and projection matrix
    m_debugProgram.hUBO = [NFRUtils createUniformBufferNamed:@"UBOData" inProgrm:m_debugProgram.hProgram];
    NSAssert(m_debugProgram.hUBO != 0, @"failed to get uniform buffer handle");
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

    //glBindBuffer(GL_UNIFORM_BUFFER, m_hUBO);
    glBindBuffer(GL_UNIFORM_BUFFER, m_phongModel.hUBO);

    // will allocate buffer's internal storage
    glBufferData(GL_UNIFORM_BUFFER, 2 * matrixSize, NULL, GL_STATIC_READ);

    // transfer view and projection matrix data to uniform buffer
    glBufferSubData(GL_UNIFORM_BUFFER, (GLintptr)0, matrixSize, viewMatrix.m);
    glBufferSubData(GL_UNIFORM_BUFFER, offset, matrixSize, projection.m);

    glBindBuffer(GL_UNIFORM_BUFFER, 0);
    CHECK_GL_ERROR();
}

@end
