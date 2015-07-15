//
//  NFRenderer.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRenderer.h"
#import "NFRUtils.h"
#import "NFRProgram.h"

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

    NFDirectionalLight* m_dirLight;
    NFPointLight* m_pointLight;

    id<NFRProgram> m_phongObject;
    id<NFRProgram> m_debugObject;

    NFRRenderRequest* m_renderRequest;
    NFRRenderRequest* m_debugRenderRequest;
}

@property (nonatomic, retain) NSArray* viewports;

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
        viewportArray[i] = [[[NFViewport alloc] init] autorelease];
        viewportArray[i].uniqueId = -1;
        viewportArray[i].viewRect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    }

    viewportArray[0].uniqueId = 1;
    viewportArray[0].viewRect = CGRectMake(0.0f, 0.0f, (CGFloat)DEFAULT_VIEWPORT_WIDTH, (CGFloat)DEFAULT_VIEWPORT_HEIGHT);
    [self setViewports:[NSArray arrayWithObjects:viewportArray count:MAX_NUM_VIEWPORTS]];

    m_phongObject = [[NFRProgram createProgramObject:@"DefaultModel"] retain];
    m_debugObject = [[NFRProgram createProgramObject:@"Debug"] retain];

    m_renderRequest = [[[NFRRenderRequest alloc] init] retain];
    [m_renderRequest setProgram:m_phongObject];

    m_debugRenderRequest = [[[NFRRenderRequest alloc] init] retain];
    [m_debugRenderRequest setProgram:m_debugObject];



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


    m_pointLight = [[[NFPointLight alloc] init] retain];
    m_dirLight = [[[NFDirectionalLight alloc] init] retain];


    _stepTransforms = NO;


    // setup OpenGL state that will never change
    //glClearColor(1.0f, 0.0f, 1.0f, 1.0f); // hot pink for debugging
    glClearColor(0.30f, 0.30f, 0.30f, 1.0f);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);

    //
    // TODO: add support for multisampling in window creation (NFView)
    //
    //glEnable(GL_MULTISAMPLE);

    //
    // TODO: add support for gamma correction
    //
    //glEnable(GL_FRAMEBUFFER_SRGB);

    CHECK_GL_ERROR();


    [m_renderRequest addGeometry:m_pAsset.geometry];
    [m_renderRequest addGeometry:m_planeData.geometry];

    [m_renderRequest addLight:m_pointLight];
    //[m_renderRequest addLight:m_dirLight];


    //[m_debugRenderRequest addGeometry:m_axisData.geometry];
    //[m_debugRenderRequest addGeometry:m_gridData.geometry];
    
    [m_debugRenderRequest addGeometry:m_pointLight.geometry];
    [m_debugRenderRequest addGeometry:m_dirLight.geometry];

    return self;
}

- (void) dealloc {
    [m_pAsset release];
    [m_axisData release];
    [m_gridData release];
    [m_planeData release];

    [m_pointLight release];
    [m_dirLight release];

    [m_phongObject release];
    [m_debugObject release];

    [m_renderRequest release];
    [m_debugRenderRequest release];

    [super dealloc];
}

- (void) updateFrameWithTime:(float)secsElapsed withViewPosition:(GLKVector3)viewPosition withViewMatrix:(GLKMatrix4)viewMatrix withProjection:(GLKMatrix4)projection {
    if (self.stepTransforms) {
        [m_pAsset stepTransforms:secsElapsed];

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
    // TODO: when in DEBUG mode check to verify that the frame buffer is valid, under some
    //       circumstances when first starting up the application the renderer can attempt
    //       to draw into a frame buffer before it is ready
    //

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    [m_renderRequest process];
    [m_debugRenderRequest process];
}

- (void) resizeToRect:(CGRect)rect {
    NFViewport *viewport = [self.viewports objectAtIndex:0];

    if (viewport.viewRect.size.width != CGRectGetWidth(rect) ||
        viewport.viewRect.size.height != CGRectGetHeight(rect)) {
        viewport.viewRect = rect;
        glViewport((GLint)0, (GLint)0, (GLsizei)CGRectGetWidth(rect), (GLsizei)CGRectGetHeight(rect));
    }
}

@end
