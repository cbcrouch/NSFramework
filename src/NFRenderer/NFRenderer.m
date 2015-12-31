//
//  NFRenderer.m
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import "NFUtils.h"

#import "NFRenderer.h"
#import "NFRUtils.h"

#import "NFRDisplayTarget.h"
#import "NFRRenderRequest.h"

//
// TODO: move NFAssetLoader and NFLightSource module test code into NFSimulation module once it has been stubbed out
//
#import "NFAssetLoader.h"
#import "NFLightSource.h"


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
    NFAssetData* m_pAsset;
    NFAssetData* m_axisData;
    NFAssetData* m_gridData;
    NFAssetData* m_planeData;

    NFAssetData* m_pProceduralData;

    NFDirectionalLight* m_dirLight;
    NFPointLight* m_pointLight;
    NFSpotLight* m_spotLight;

    id<NFRProgram> m_phongObject;
    id<NFRProgram> m_debugObject;

    NFRCommandBufferDefault* m_defaultCmdBuffer;
    NFRCommandBufferDebug* m_debugCmdBuffer;

    NFRRenderRequest* m_renderRequest;
    NFRRenderRequest* m_debugRenderRequest;

    NFRRenderTarget* m_renderTarget;
    NFRDisplayTarget* m_displayTarget;
}

@property (nonatomic, strong) NSArray* viewports;

@end

#pragma mark - NSGLRenderer Implementation
@implementation NFRenderer

- (instancetype) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    //
    // NOTE: currently the renderer init is what is driving much of the debug and test code, most of this
    //       will eventually be moved or removed
    //

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
        viewportArray[i] = [[NFViewport alloc] init];
        viewportArray[i].uniqueId = -1;
        viewportArray[i].viewRect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    }

    viewportArray[0].uniqueId = 1;
    viewportArray[0].viewRect = CGRectMake(0.0f, 0.0f, (CGFloat)DEFAULT_VIEWPORT_WIDTH, (CGFloat)DEFAULT_VIEWPORT_HEIGHT);
    self.viewports = [NSArray arrayWithObjects:viewportArray count:MAX_NUM_VIEWPORTS];

    // shader objects
    m_phongObject = [NFRUtils createProgramObject:@"DefaultModel"];
    m_debugObject = [NFRUtils createProgramObject:@"Debug"];

    // command buffers
    m_defaultCmdBuffer = [[NFRCommandBufferDefault alloc] init];
    m_debugCmdBuffer = [[NFRCommandBufferDebug alloc] init];


    //
    // TODO: add a render request that will render to a depth buffer for shadow mapping
    //       (will need one render request per dynamic light)
    //

    // render requests
    m_renderRequest = [[NFRRenderRequest alloc] init];
    m_renderRequest.program = m_phongObject;

    m_debugRenderRequest = [[NFRRenderRequest alloc] init];
    m_debugRenderRequest.program = m_debugObject;


    //
    // TODO: move render target ownership into the render request
    //
    m_renderTarget = [[NFRRenderTarget alloc] init];

    m_displayTarget = [[NFRDisplayTarget alloc] init];
    m_displayTarget.transferSource = m_renderTarget;



    NSString *fileNamePath;

    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/cube/cube.obj";
    //fileNamePath = @"/Users/cayce/Developer/NSGL/Models/cube/cube-mod.obj";
    fileNamePath = @"/Users/cayce/Developer/NSGL/Models/leftsphere/leftsphere.obj";

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
    [m_pAsset generateRenderables];

    //m_pAsset.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 1.0f, 0.0f);
    //[m_pAsset stepTransforms:0.0f];

    //[m_pAsset applyOriginCenterMatrix];
    //[m_pAsset applyUnitScalarMatrix]; // use for teapot



    m_axisData = [NFAssetLoader allocAssetDataOfType:kAxisWireframe withArgs:nil];
    [m_axisData generateRenderables];


    m_gridData = [NFAssetLoader allocAssetDataOfType:kGridWireframe withArgs:nil];
    [m_gridData generateRenderables];


    m_planeData = [NFAssetLoader allocAssetDataOfType:kSolidPlane withArgs:nil];
    [m_planeData generateRenderables];


    //
    // NOTE: this asset is just for testing the rotate vector to direction method
    //
    //ASSET_TYPE assetType = kSolidCylinder;
    ASSET_TYPE assetType = kSolidCone;
    m_pProceduralData = [NFAssetLoader allocAssetDataOfType:assetType withArgs:@(kVertexFormatDefault), nil];

    GLKVector3 position = GLKVector3Make(1.0f, 1.0f, -1.0f);

    m_pProceduralData.modelMatrix = GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, position);

    //m_pProceduralData.modelMatrix = GLKMatrix4Scale(m_pProceduralData.modelMatrix, 0.35f, 0.35f, 0.35f);
    m_pProceduralData.modelMatrix = GLKMatrix4Scale(m_pProceduralData.modelMatrix, 0.5f, 0.5f, 0.5f);

    //
    // NOTE: can't use the actual position but need to use the normal vector of the fact that you want
    //       to rotate towards a given destination, and the destination vector must be a vector from the
    //       position of the normal vector to the desired location that normal vector will face
    //
    GLKVector3 orig = GLKVector3Make(0.0f, 1.0f, 0.0f);
    orig = GLKVector3Normalize(orig);

    // NOTE: this should always make the geometry face the origin
    GLKVector3 dest = GLKVector3MultiplyScalar(position, -1.0f);
    dest = GLKVector3Normalize(dest);

    GLKQuaternion rotationQuat = [NFUtils rotateVector:orig toDirection:dest];

    // NOTE: this will make the top face of the cylinder point towards the origin
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeWithQuaternion(rotationQuat);
    m_pProceduralData.modelMatrix = GLKMatrix4Multiply(m_pProceduralData.modelMatrix, rotationMatrix);

    [m_pProceduralData generateRenderables];
    //
    //
    //


    m_pointLight = [[NFPointLight alloc] init];
    m_dirLight = [[NFDirectionalLight alloc] init];
    m_spotLight = [[NFSpotLight alloc] init];


    _stepTransforms = NO;


    //
    // TODO: move these operations into the render target or render request class
    //

    // setup OpenGL state that will never change
    //glClearColor(1.0f, 0.0f, 1.0f, 1.0f); // hot pink for debugging

    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
    //glClearColor(0.05f, 0.05f, 0.05f, 1.0f); // use with GL_FRAMEBUFFER_SRGB enabled

    //
    // TODO: modify depth function to increase near view precision
    //
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    glEnable(GL_CULL_FACE);

    //
    // TODO: add support for multisampling in window creation (NFView)
    //
    //glEnable(GL_MULTISAMPLE);
    //glEnable(GL_FRAMEBUFFER_SRGB);

    CHECK_GL_ERROR();

    //
    //
    //

    // add renderables to command buffers
    [m_defaultCmdBuffer addGeometry:m_pAsset.geometry];
    [m_defaultCmdBuffer addGeometry:m_planeData.geometry];
    [m_defaultCmdBuffer addGeometry:m_pProceduralData.geometry];

    [m_defaultCmdBuffer addLight:m_pointLight];
    [m_defaultCmdBuffer addLight:m_dirLight];
    [m_defaultCmdBuffer addLight:m_spotLight];

    [m_debugCmdBuffer addGeometry:m_axisData.geometry];
    //[m_debugCmdBuffer addGeometry:m_gridData.geometry];

    [m_debugCmdBuffer addGeometry:m_pointLight.geometry];
    [m_debugCmdBuffer addGeometry:m_dirLight.geometry];
    [m_debugCmdBuffer addGeometry:m_spotLight.geometry];

    // add command buffers to render requests
    [m_renderRequest.commandBufferArray addObject:m_defaultCmdBuffer];
    [m_debugRenderRequest.commandBufferArray addObject:m_debugCmdBuffer];

    return self;
}


- (void) updateFrameWithTime:(float)secsElapsed withViewPosition:(GLKVector3)viewPosition withViewMatrix:(GLKMatrix4)viewMatrix withProjection:(GLKMatrix4)projection {
    if (self.stepTransforms) {
        [m_pAsset stepTransforms:secsElapsed];
        [m_pProceduralData stepTransforms:secsElapsed];

        [m_pointLight stepTransforms:secsElapsed];
    }

    //
    // TODO: need to either send in a dirty flag or cache the values and compare so that the
    //       renderer is not updating the UBO every frame
    //

    [m_phongObject updateViewPosition:viewPosition];
    [m_phongObject updateViewMatrix:viewMatrix projectionMatrix:projection];

    [m_debugObject updateViewMatrix:viewMatrix projectionMatrix:projection];
}

- (void) renderFrame {
    //
    // TODO: when in DEBUG mode check to verify that the default frame buffer is valid, under
    //       some circumstances when first starting up the application the renderer can attempt
    //       to draw into a frame buffer before it is ready
    //

#define USE_RENDER_TARGET 1

#if USE_RENDER_TARGET
    [m_renderTarget enable]; // sets FBO to be drawn to
#endif

    //
    // TODO: move clear call setting into render request and start implementing shadow mapping
    //       (for shadow mapping will most likely need an array of render requets/targets per
    //       light in order to generate shadow maps for each light)
    //
    //       render target will need more options so that it can be configured for either an
    //       FBO backing or to render to texture
    //

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    [m_renderRequest process];
    [m_debugRenderRequest process];

#if USE_RENDER_TARGET
    [m_renderTarget disable];

    [m_displayTarget processTransfer];
#endif
}

- (void) resizeToRect:(CGRect)rect {

    //
    // TODO: render target needs to be resized, will need a way to link this all together when render targets
    //       have been integrated into render requests
    //

    const uint32_t width = (uint32_t)CGRectGetWidth(rect);
    const uint32_t height = (uint32_t)CGRectGetHeight(rect);
    if (m_renderTarget.width != width || m_renderTarget.height != height) {
        [m_renderTarget resizeWithWidth:width withHeight:height];
    }

    //
    // TODO: move/merge this into NFRViewport or keep separate and rename NFRViewport
    //
    NFViewport *viewport = (self.viewports)[0];
    if (viewport.viewRect.size.width != CGRectGetWidth(rect) || viewport.viewRect.size.height != CGRectGetHeight(rect)) {
        viewport.viewRect = rect;
        glViewport((GLint)0, (GLint)0, (GLsizei)CGRectGetWidth(rect), (GLsizei)CGRectGetHeight(rect));
    }
}

@end
