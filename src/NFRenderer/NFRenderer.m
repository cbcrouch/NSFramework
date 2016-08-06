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

//
// TODO: remove NFRDefaultProgram module once light space matrix has been moved into the light classes
//       and then the uniform update can occur in NFRDefaultProgram loadLight method
//
#import "NFRDefaultProgram.h"

//
// TODO: try restructing so that the uniforms for the point depth program can be updated elsewhere
//       so that this dependency can be removed (this module should ideally have no internal knowledge
//       of shaders if possible)
//
#import "NFRPointDepthProgram.h"

//
// TODO: setup a cube map and render as an environment map
//
#import "NFAssetUtils.h"
#import "NFRDataMap.h"



// NOTE: because both gl.h and gl3.h are included will get symbols for deprecated GL functions
//       and they should absolutely not be used
#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>

#import <GLKit/GLKit.h>


static uint32_t const SHADOW_WIDTH = 1024;
static uint32_t const SHADOW_HEIGHT = 1024;


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

    NFRCubeMap* m_skyBox;
    NFAssetData* m_skyBoxData;

    id<NFRProgram> m_phongShader;
    id<NFRProgram> m_debugShader;
    id<NFRProgram> m_directionalDepthShader;
    id<NFRProgram> m_pointDepthShader;
    id<NFRProgram> m_cubeMapShader;

    NFRCommandBufferDefault* m_defaultCmdBuffer;
    NFRCommandBufferDebug* m_debugCmdBuffer;

    NFRRenderRequest* m_renderRequest;
    NFRRenderRequest* m_debugRenderRequest;

    // background sky box
    NFRCommandBufferDefault* m_skyBoxCmdBuffer;
    NFRRenderRequest* m_skyBoxRenderRequest;

    // depth map for directional light shadow
    NFRCommandBufferDefault* m_depthCmdBuffer;
    NFRRenderRequest* m_depthRenderRequest;
    NFRRenderTarget* m_depthRenderTarget;

    // depth (cube) map for point light shadow
    NFRCommandBufferDefault* m_pointLightDepthCmdBuffer;
    NFRRenderRequest* m_pointLightDepthRenderRequest;
    NFRRenderTarget* m_pointLightDepthRenderTarget;

    //
    // TODO: implement a way to batch shadow generation for N lights of the three given types
    //       (directional, point light, spotlight)
    //
/*
    NFRCommandBufferDefault* m_shadowMapCmdBuffers[3];
    NFRRenderRequest* m_shadowMapRequests[3];
    NFRRenderTarget* m_shadowMapTargets[3];
*/

    NFRRenderTarget* m_renderTarget;
    NFRDisplayTarget* m_displayTarget;
}

@property (nonatomic, strong) NSArray* viewports;

@end



#define RENDER_DEPTH_BUFFER 0
#define DIRECTIONAL_LIGHT_TARGET 0


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
    m_phongShader = [NFRUtils createProgramObject:@"DefaultModel"];
    m_debugShader = [NFRUtils createProgramObject:@"Debug"];
    m_directionalDepthShader = [NFRUtils createProgramObject:@"DirectionalDepthMap"];
    m_pointDepthShader = [NFRUtils createProgramObject:@"PointDepthMap"];
    m_cubeMapShader = [NFRUtils createProgramObject:@"CubeMap"];

    // command buffers
    m_defaultCmdBuffer = [[NFRCommandBufferDefault alloc] init];
    m_debugCmdBuffer = [[NFRCommandBufferDebug alloc] init];
    m_depthCmdBuffer = [[NFRCommandBufferDefault alloc] init];
    m_pointLightDepthCmdBuffer = [[NFRCommandBufferDefault alloc] init];
    m_skyBoxCmdBuffer = [[NFRCommandBufferDefault alloc] init];

    // render requests
    m_renderRequest = [[NFRRenderRequest alloc] init];
    m_renderRequest.program = m_phongShader;

    m_debugRenderRequest = [[NFRRenderRequest alloc] init];
    m_debugRenderRequest.program = m_debugShader;

    m_depthRenderRequest = [[NFRRenderRequest alloc] init];
    m_depthRenderRequest.program = m_directionalDepthShader;

    m_pointLightDepthRenderRequest = [[NFRRenderRequest alloc] init];
    m_pointLightDepthRenderRequest.program = m_pointDepthShader;

    m_skyBoxRenderRequest = [[NFRRenderRequest alloc] init];
    m_skyBoxRenderRequest.program = m_cubeMapShader;


    //
    // TODO: move render target ownership into the render request ??
    //
    m_renderTarget = [[NFRRenderTarget alloc] init];
    [m_renderTarget addAttachment:kColorAttachment withBackingBuffer:kTextureBuffer];

    //
    // TODO: switch back to a depth/stencil attachment with a render buffer backing once
    //       able to confirm that display depth texture works correctly
    //
    //[m_renderTarget addAttachment:kDepthStencilAttachment withBackingBuffer:kRenderBuffer];
    [m_renderTarget addAttachment:kDepthAttachment withBackingBuffer:kTextureBuffer];


    m_depthRenderTarget = [[NFRRenderTarget alloc] init];
    [m_depthRenderTarget addAttachment:kColorAttachment withBackingBuffer:kRenderBuffer];
    [m_depthRenderTarget addAttachment:kDepthAttachment withBackingBuffer:kTextureBuffer];


    m_pointLightDepthRenderTarget = [[NFRRenderTarget alloc] initWithWidth:SHADOW_WIDTH withHeight:SHADOW_HEIGHT];

    //
    // TODO: shouldn't need a render buffer for the point light depth maps, though need to make sure that
    //       OpenGL and the render target implementation can handle it
    //
    //[m_pointLightDepthRenderTarget addAttachment:kColorAttachment withBackingBuffer:kRenderBuffer];
    //[m_pointLightDepthRenderTarget addAttachment:kColorAttachment withBackingBuffer:kTextureBuffer];

    [m_pointLightDepthRenderTarget addAttachment:kDepthAttachment withBackingBuffer:kCubeMapBuffer];


    m_displayTarget = [[NFRDisplayTarget alloc] init];

#if DIRECTIONAL_LIGHT_TARGET
    m_displayTarget.transferSource = m_depthRenderTarget;
#else
    m_displayTarget.transferSource = m_renderTarget;
#endif


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


    NSString* cubeMapPath = @"/Users/cayce/Developer/NSGL/Textures/Yokohama3";
    m_skyBox = [[NFRCubeMap alloc] init];

    // faces must be loaded in the same order as the GL cube map positions
    NFRDataMap* dataMap = [NFAssetUtils parseTextureFile:[cubeMapPath stringByAppendingPathComponent:@"posx.jpg"] flipVertical:NO];
    [m_skyBox loadFace:0 withData:dataMap.data ofSize:CGRectMake(0.0f, 0.0f, (float)dataMap.width, (float)dataMap.height) ofType:dataMap.type withFormat:dataMap.format];

    dataMap = [NFAssetUtils parseTextureFile:[cubeMapPath stringByAppendingPathComponent:@"negx.jpg"] flipVertical:NO];
    [m_skyBox loadFace:1 withData:dataMap.data ofSize:CGRectMake(0.0f, 0.0f, (float)dataMap.width, (float)dataMap.height) ofType:dataMap.type withFormat:dataMap.format];

    dataMap = [NFAssetUtils parseTextureFile:[cubeMapPath stringByAppendingPathComponent:@"posy.jpg"] flipVertical:NO];
    [m_skyBox loadFace:2 withData:dataMap.data ofSize:CGRectMake(0.0f, 0.0f, (float)dataMap.width, (float)dataMap.height) ofType:dataMap.type withFormat:dataMap.format];

    dataMap = [NFAssetUtils parseTextureFile:[cubeMapPath stringByAppendingPathComponent:@"negy.jpg"] flipVertical:NO];
    [m_skyBox loadFace:3 withData:dataMap.data ofSize:CGRectMake(0.0f, 0.0f, (float)dataMap.width, (float)dataMap.height) ofType:dataMap.type withFormat:dataMap.format];

    dataMap = [NFAssetUtils parseTextureFile:[cubeMapPath stringByAppendingPathComponent:@"posz.jpg"] flipVertical:NO];
    [m_skyBox loadFace:4 withData:dataMap.data ofSize:CGRectMake(0.0f, 0.0f, (float)dataMap.width, (float)dataMap.height) ofType:dataMap.type withFormat:dataMap.format];

    dataMap = [NFAssetUtils parseTextureFile:[cubeMapPath stringByAppendingPathComponent:@"negz.jpg"] flipVertical:NO];
    [m_skyBox loadFace:5 withData:dataMap.data ofSize:CGRectMake(0.0f, 0.0f, (float)dataMap.width, (float)dataMap.height) ofType:dataMap.type withFormat:dataMap.format];

    m_skyBoxData = [NFAssetLoader allocAssetDataOfType:kCubeMapGeometry withArgs:nil];
    [m_skyBoxData generateRenderables];

    [m_skyBoxData.geometry assignCubeMap:m_skyBox];


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

    GLKVector3 modelVec = GLKVector3Make(0.0f, 1.0f, 0.0f);
    modelVec = GLKVector3Normalize(modelVec);

    // NOTE: this should always make the geometry face the origin
    GLKVector3 dest = GLKVector3MultiplyScalar(position, -1.0f);
    dest = GLKVector3Normalize(dest);

    GLKQuaternion rotationQuat = [NFUtils rotateVector:modelVec toDirection:dest];

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
    // TODO: command buffer should have a generic add resource method
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

    // sky box
    [m_skyBoxCmdBuffer addGeometry:m_skyBoxData.geometry];
    [m_skyBoxRenderRequest.commandBufferArray addObject:m_skyBoxCmdBuffer];

    // directional shadow map
    [m_depthCmdBuffer addGeometry:m_pAsset.geometry];
    //[m_depthCmdBuffer addGeometry:m_planeData.geometry];
    [m_depthCmdBuffer addGeometry:m_pProceduralData.geometry];

    // point light shadow map
    [m_pointLightDepthCmdBuffer addGeometry:m_pAsset.geometry];
    //[m_pointLightDepthCmdBuffer addGeometry:m_planeData.geometry];
    [m_pointLightDepthCmdBuffer addGeometry:m_pProceduralData.geometry];

    // add command buffers to render requests
    [m_renderRequest.commandBufferArray addObject:m_defaultCmdBuffer];
    [m_debugRenderRequest.commandBufferArray addObject:m_debugCmdBuffer];

    [m_depthRenderRequest.commandBufferArray addObject:m_depthCmdBuffer];
    [m_pointLightDepthRenderRequest.commandBufferArray addObject:m_pointLightDepthCmdBuffer];

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

    [m_phongShader updateViewPosition:viewPosition];
    [m_phongShader updateViewMatrix:viewMatrix projectionMatrix:projection];

    // update view and projection matrix for drawing skybox
    [m_cubeMapShader updateViewMatrix:viewMatrix projectionMatrix:projection];

    //
    // TODO need a faster way of building view matrices
    //
    GLKVector3 eye = GLKVector3Make(-2.0f, 2.0f, 1.0f);
    //GLKVector3 eye = GLKVector3Make(-4.0f, 4.0f, 2.0f);
    //GLKVector3 eye = GLKVector3Make(-2.0f, 4.0f, -1.0f);

    GLKVector3 dest = GLKVector3Make(0.0f, 0.0f, 0.0f);

    GLKVector3 hyp = GLKVector3Subtract(eye, dest);
    hyp = GLKVector3Normalize(hyp);

    float yaw = -M_PI + atan2f(hyp.x, hyp.z);
    float pitch = -atan2(hyp.y, hyp.y) / 2.0f;

    GLKVector3 look;
    float r = cosf(pitch);
    look.x = r * sinf(yaw);
    look.y = sinf(pitch);
    look.z = r * cosf(yaw);

    GLKVector3 right;
    right.x = sinf(yaw - M_PI_2);
    right.y = 0.0f;
    right.z = cosf(yaw - M_PI_2);

    GLKVector3 up = GLKVector3CrossProduct(right, look);

    GLKMatrix4 lightViewMat = GLKMatrix4MakeLookAt(eye.x, eye.y, eye.z,
                                       look.x, look.y, look.z,
                                       up.x, up.y, up.z);

    //
    // TODO: settle on a good projection matrix
    //
    //GLKMatrix4 orthoProj = GLKMatrix4MakeOrtho(-10.0, 10.0, -10.0, 10.0, -1.0, 20.0);
    GLKMatrix4 orthoProj = GLKMatrix4MakeOrtho(-2.5, 2.5, -2.5, 2.5, -1.0, 20.0);

    //GLKMatrix4 orthoProj = GLKMatrix4MakeOrtho(-10.0, 10.0, -10.0, 10.0, -2.0, 5.0); // for testing light/shadow cutoff correction

    //
    // TODO: try using a perspective projection for the spotlight shadow map
    //

    [m_directionalDepthShader updateViewMatrix:lightViewMat projectionMatrix:orthoProj];
    //[m_directionalDepthShader updateViewMatrix:lightViewMat projectionMatrix:projection];


    float aspect = (float)SHADOW_WIDTH / (float)SHADOW_HEIGHT;
    float near = 0.05f;
    float far = 100.0f;
    GLKMatrix4 pointShadowProj = GLKMatrix4MakePerspective((float)M_PI_2, aspect, near, far);

    GLKVector3 yNegUp = GLKVector3Make(0.0, -1.0, 0.0);
    GLKVector3 zPosUp = GLKVector3Make(0.0, 0.0, 1.0);
    GLKVector3 zNegUp = GLKVector3Make(0.0, 0.0, -1.0);

    GLKVector3 pointLightPos = m_pointLight.position;

    GLKVector3 temp;
    GLKMatrix4 shadowTransforms[6];

    temp = GLKVector3Add(pointLightPos, GLKVector3Make(1.0, 0.0, 0.0));
    shadowTransforms[0] = GLKMatrix4MakeLookAt(pointLightPos.x, pointLightPos.y, pointLightPos.z, temp.x, temp.y, temp.z, yNegUp.x, yNegUp.y, yNegUp.z);
    shadowTransforms[0] = GLKMatrix4Multiply(pointShadowProj, shadowTransforms[0]);

    temp = GLKVector3Add(pointLightPos, GLKVector3Make(-1.0, 0.0, 0.0));
    shadowTransforms[1] = GLKMatrix4MakeLookAt(pointLightPos.x, pointLightPos.y, pointLightPos.z, temp.x, temp.y, temp.z, yNegUp.x, yNegUp.y, yNegUp.z);
    shadowTransforms[1] = GLKMatrix4Multiply(pointShadowProj, shadowTransforms[1]);

    temp = GLKVector3Add(pointLightPos, GLKVector3Make(0.0, 1.0, 0.0));
    shadowTransforms[2] = GLKMatrix4MakeLookAt(pointLightPos.x, pointLightPos.y, pointLightPos.z, temp.x, temp.y, temp.z, zPosUp.x, zPosUp.y, zPosUp.z);
    shadowTransforms[2] = GLKMatrix4Multiply(pointShadowProj, shadowTransforms[2]);

    temp = GLKVector3Add(pointLightPos, GLKVector3Make(0.0, -1.0, 0.0));
    shadowTransforms[3] = GLKMatrix4MakeLookAt(pointLightPos.x, pointLightPos.y, pointLightPos.z, temp.x, temp.y, temp.z, zNegUp.x, zNegUp.y, zNegUp.z);
    shadowTransforms[3] = GLKMatrix4Multiply(pointShadowProj, shadowTransforms[3]);

    temp = GLKVector3Add(pointLightPos, GLKVector3Make(0.0, 0.0, 1.0));
    shadowTransforms[4] = GLKMatrix4MakeLookAt(pointLightPos.x, pointLightPos.y, pointLightPos.z, temp.x, temp.y, temp.z, yNegUp.x, yNegUp.y, yNegUp.z);
    shadowTransforms[4] = GLKMatrix4Multiply(pointShadowProj, shadowTransforms[4]);

    temp = GLKVector3Add(pointLightPos, GLKVector3Make(0.0, 0.0, -1.0));
    shadowTransforms[5] = GLKMatrix4MakeLookAt(pointLightPos.x, pointLightPos.y, pointLightPos.z, temp.x, temp.y, temp.z, yNegUp.x, yNegUp.y, yNegUp.z);
    shadowTransforms[5] = GLKMatrix4Multiply(pointShadowProj, shadowTransforms[5]);

    if ([m_pointDepthShader respondsToSelector:@selector(updateFarPlane:)]) {
        [m_pointDepthShader performSelector:@selector(updateFarPlane:) withObject:@(far)];
    }

    if ([m_pointDepthShader respondsToSelector:@selector(updateLightPosition:)]) {
        static const char* vecType = @encode(GLKVector3);
        NSValue* valueObj = [NSValue value:&pointLightPos withObjCType:vecType];
        [m_pointDepthShader performSelector:@selector(updateLightPosition:) withObject:valueObj];
    }

    if ([m_pointDepthShader respondsToSelector:@selector(updateCubeMapTransforms:)]) {
        static const char* matType = @encode(GLKMatrix4);
        NSMutableArray* transformsArray = [[NSMutableArray alloc] initWithCapacity:6];

        for (int i=0; i<6; ++i) {
            NSValue* valueObj = [NSValue value:&(shadowTransforms[i]) withObjCType:matType];
            [transformsArray addObject:valueObj];
        }

        [m_pointDepthShader performSelector:@selector(updateCubeMapTransforms:) withObject:transformsArray];
    }


    //
    // TODO: move the light space matrix into the light classes and have the uniform get updated
    //       in the NFRDefaultModel loadLight method
    //
    if ([m_phongShader respondsToSelector:@selector(updateLightSpaceMatrix:)]) {
        //
        // NOTE: should make sure that the light space matrix calculation only happens once
        //
        GLKMatrix4 lightSpaceMat = GLKMatrix4Multiply(orthoProj, lightViewMat);
        //GLKMatrix4 lightSpaceMat = GLKMatrix4Multiply(projection, lightViewMat);

        static const char *matrixType = @encode(GLKMatrix4);
        NSValue* valueObj = [NSValue value:&lightSpaceMat withObjCType:matrixType];
        [m_phongShader performSelector:@selector(updateLightSpaceMatrix:) withObject:valueObj];
    }


    [m_debugShader updateViewMatrix:viewMatrix projectionMatrix:projection];
}

- (void) renderFrame {
    //
    // TODO: when in DEBUG mode check to verify that the default frame buffer is valid, under
    //       some circumstances when first starting up the application the renderer can attempt
    //       to draw into a frame buffer before it is ready
    //


    // directional light shadow map
    [m_depthRenderTarget enable];
    glClear(GL_DEPTH_BUFFER_BIT);
    glCullFace(GL_FRONT);
    [m_depthRenderRequest process];
    [m_depthRenderTarget disable];
    glCullFace(GL_BACK);


    // point light shadow map
    [m_pointLightDepthRenderTarget enable];
    glClear(GL_DEPTH_BUFFER_BIT);
    glCullFace(GL_FRONT);
    [m_pointLightDepthRenderRequest process];
    [m_pointLightDepthRenderTarget disable];
    glCullFace(GL_BACK);


    //
    // TODO: need a better way to get the shadow map texture (depth tex attachment) pass into the
    //       default model shader for each light
    //
    if ([m_phongShader respondsToSelector:@selector(setShadowMap:)]) {
        static const char *handleType = @encode(GLint);
        GLint depthTexHandle = (GLint)m_depthRenderTarget.depthAttachment.handle;
        NSValue* valueObj = [NSValue value:&depthTexHandle withObjCType:handleType];
        [m_phongShader performSelector:@selector(setShadowMap:) withObject:valueObj];
    }

    if ([m_phongShader respondsToSelector:@selector(setPointShadowMap:)]) {
        static const char *handleType = @encode(GLint);
        GLint depthTexHandle = (GLint)m_pointLightDepthRenderTarget.depthAttachment.handle;
        NSValue* valueObj = [NSValue value:&depthTexHandle withObjCType:handleType];

        //
        // TODO: restore sky box after finished debugging the point light shadows
        //
        [m_skyBoxData.geometry assignCubeMapHandle:valueObj];

        [m_phongShader performSelector:@selector(setPointShadowMap:) withObject:valueObj];
    }


    [m_renderTarget enable]; // sets FBO to be drawn to

    //
    // TODO: move clear call setting into render request and start implementing shadow mapping
    //       (for shadow mapping will most likely need an array of render requets/targets per
    //       light in order to generate shadow maps for each light)
    //
    //       render target will need more options so that it can be configured for either an
    //       FBO backing or to render to texture
    //

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    // render sky box background
    glDepthMask(GL_FALSE);
    [m_skyBoxRenderRequest process];
    glDepthMask(GL_TRUE);

    [m_renderRequest process];
    [m_debugRenderRequest process];

    [m_renderTarget disable];


#if RENDER_DEPTH_BUFFER
    [m_displayTarget processTransferOfAttachment:kDepthAttachment];
#else
    [m_displayTarget processTransferOfAttachment:kColorAttachment];
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
