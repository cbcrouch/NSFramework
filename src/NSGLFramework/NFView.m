//
//  NFView.m
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

// application headers
#import "NFView.h"
#import "NFRenderer.h"
#import "NFViewVolume.h"

// Cocoa headers
#import <QuartzCore/CVDisplayLink.h>


//
// TODO: NFCamera should only temporarily be used by NFView, should be moved
//       to the simulation/application module
//
#import "NFCamera.h"

/*
@interface NFArcBall : NSObject

@property (nonatomic, assign) NSInteger lastX;
@property (nonatomic, assign) NSInteger lastY;
@property (nonatomic, assign) NSInteger currentX;
@property (nonatomic, assign) NSInteger currentY;

@property (nonatomic, assign) CGSize viewportSize;
@property (nonatomic, assign) BOOL active;

//
// TODO: need to lock the arc ball while computing the rotation matrix
//       (i.e. this will need to be made thread safe)
//
- (GLKMatrix4) getRotationMatrix;

@end

@interface NFArcBall()

- (GLKVector4) getVectorWithX:(NSInteger)x withY:(NSInteger)y;

@end

@implementation NFArcBall

@synthesize currentX = _currentX;
@synthesize currentY = _currentY;

@synthesize viewportSize = _viewportSize;
@synthesize active = _active;

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        [self setLastX:0];
        [self setLastY:0];
        [self setCurrentX:0];
        [self setCurrentY:0];
        [self setViewportSize:CGSizeMake(0.0f, 0.0f)];
        [self setActive:NO];
    }
    return self;
}

- (GLKVector4) getVectorWithX:(NSInteger)x withY:(NSInteger)y {

    //
    // TODO: this method has not yet been tested and can drop usage
    //       of the multiplicative identity
    //

    GLKVector4 P = GLKVector4Make(1.0f * (x / self.viewportSize.width) * 2.0f - 1.0f,
                                  1.0f * (y / self.viewportSize.height) * 2.0f -1.0f,
                                  0.0f, 0.0f);
    P.v[1] = -P.v[1];

    float opSquare = (P.v[0] * P.v[0]) + (P.v[1] * P.v[1]);
    if (opSquare <= 1.0f) {
        P.v[2] = sqrtf(1.0f - opSquare);
    }
    else {
        P = GLKVector4Normalize(P);
    }

    return P;
}

//
// TODO: this arc ball calculation is to rotate an object, not the camera, will need to modify
//       to work with the NFCamera class (but will still want the ability to generate a rotation
//       matrix in order to manipulate various geometry in the scene)
//

- (GLKMatrix4) getRotationMatrix {

    //
    // TODO: convert snippet from wikibook to ObjC
    //


    GLKVector4 va = [self getVectorWithX:self.lastX withY:self.lastY];
    GLKVector4 vb = [self getVectorWithX:self.currentX withY:self.currentY];

    float angle = acosf(min(1.0f, GLKVector4DotProduct(va, vb)));
    GLKVector4 axisCameraCoord = GLKVector4CrossProduct(va, vb);
 
 
 //
 // TODO: what is transforms[MODE_CAMERA] and objectToWorld set as ??
 //

    //GLKMatrix4 cameraToObject = GLKMatrix4Invert(transfroms[MODE_CAMERA] * objectToWorld, NO);
    //GLKVector4 axisObjectCoord = cameraToObject * axisCameraCoord;

    //GLKMatrix4 = GLKMatrix4Rotate(originalMatrix, angle, axisObjectCoord.v[0], axisObjectCoord.v[1], axisObjectCoord.v[2]);


    self.lastX = self.currentX;
    self.lastY = self.currentY;

#if 0
    glm::vec3 va = get_arcball_vector(last_mx, last_my);
    glm::vec3 vb = get_arcball_vector( cur_mx,  cur_my);

    float angle = acos(min(1.0f, glm::dot(va, vb)));

    glm::vec3 axis_in_camera_coord = glm::cross(va, vb);

    glm::mat3 camera2object = glm::inverse(glm::mat3(transforms[MODE_CAMERA]) * glm::mat3(mesh.object2world));
    glm::vec3 axis_in_object_coord = camera2object * axis_in_camera_coord;

    mesh.object2world = glm::rotate(mesh.object2world, glm::degrees(angle), axis_in_object_coord);

    last_mx = cur_mx;
    last_my = cur_my;
#endif

    return GLKMatrix4Make(0.0f, 0.0f, 0.0f, 0.0f,
                          0.0f, 0.0f, 0.0f, 0.0f,
                          0.0f, 0.0f, 0.0f, 0.0f,
                          0.0f, 0.0f, 0.0f, 0.0f);

}

@end
*/


//
// TODO: when ultimatly making cross platform window configuration consider passing
//       an EGL configuration and context attribute as the interface to the abstracted
//       window
//

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now,
                                    const CVTimeStamp* outputTime, CVOptionFlags flagsIn,
                                    CVOptionFlags* flagsOut, void* displayLinkContext);

@interface NFView()
{
    //
    // TODO: implement and use an NSResources group with two classes NSResourceLoader (class methods) and
    //       NSResourceCache that will aid in streaming assets to an NSGLScene/NSScene
    //

    //double m_currHostFreq; // ticks per second
    //uint32_t m_minHostDelta; // number of ticks accuracy
}

@property (nonatomic, assign) CVDisplayLinkRef displayLink;

//
// TODO: support full display rendering with CGL for "game" mode
//       and add support for OS X fullscreen mode
//
@property (nonatomic, retain) NSOpenGLContext *glContext;
@property (nonatomic, retain) NSOpenGLPixelFormat *pixelFormat;

@property (nonatomic, retain) NFRenderer *glRenderer;
@property (nonatomic, retain) NFCamera *camera;




//
// TODO: these properties will need a better home ??
//

// NFCursorController ??

@property (nonatomic, assign) NSPoint mouseLocation;

@property (nonatomic, assign) BOOL onLeftEdge;
@property (nonatomic, assign) BOOL onRightEdge;
@property (nonatomic, assign) BOOL onUpperEdge;
@property (nonatomic, assign) BOOL onLowerEdge;




// instance methods
- (void) setupTiming;
- (void) setupOpenGL;
- (void) initRenderer;
- (void) setupDisplayLink;

@end

@implementation NFView

@synthesize displayLink = _displayLink;
@synthesize glContext = _glContext;
@synthesize pixelFormat = _pixelFormat;

@synthesize glRenderer = _glRenderer;
@synthesize camera = _camera;

//
// TODO: shouldn't be performing error checking beyond debug asserts but rather have the platform
//       detection/analysis code determine whether the application will run or not
//

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now,
                                    const CVTimeStamp* outputTime, CVOptionFlags flagsIn,
                                    CVOptionFlags* flagsOut, void* displayLinkContext) {
    CVReturn result = [(NFView*)displayLinkContext getFrameForTime:outputTime];
    assert(result == kCVReturnSuccess);
    return result;
}

//
// TODO: add some NOTEs explaining why initWithFrame won't get called and initWithCoder will
//       plus include some text on why both are implemented
//
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) {
        NSLog(@"failed initWithFrame");
    }
    else {
        [self setupTiming];
        [self setupOpenGL];
        [self initRenderer];
    }

    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self == nil) {
        NSLog(@"failed initWithCode");
    }
    else {
        [self setupTiming];
        [self setupOpenGL];
        [self initRenderer];
    }

    return self;
}

- (void) dealloc {
    //
    // TODO: make sure dealloc is cleaning everything up (i.e. do events need to be unregisterd etc.)
    //

    // stop the display link BEFORE releasing anything in the view
    // otherwise the display link thread may call into the view and crash
    // when it encounters something that has been release
    CVDisplayLinkStop(self.displayLink);

    // TODO: verify won't fail on a NULL display link pointer

    // NOTE: display link does not have a destroy or retain count method, going to assume that only
    //       one can be retained per application
    CVDisplayLinkRelease(self.displayLink);

    // call NSView (parent class) dealloc
    [super dealloc];
}

- (void) awakeFromNib {
    // NOTE: since using a custom NSView subclass will need to register an observer for the
    //       NSViewGlobalFrameDidChangeNotification which is posted whenever the attached
    //       NSSurface changes size or screens
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(surfaceNeedsUpdate:)
                                                 name:NSViewGlobalFrameDidChangeNotification
                                               object:self];
}

// NOTE: not using prepareOpenGL method as it appears to get called indirectly through the
//       NSOpenGLContext class' view member (which is this view), the reason for this is to
//       have fine grained control over the view
//- (void) prepareOpenGL {
//    NSLog(@"prepareOpenGL");
//}

// TODO: setup some kind of catch all method to attempt to see who is trying to call what
//       on the NFView (i.e. self)

// TODO: add comment summarizing Apple documentation about why method should be overridden
- (BOOL) isOpaque {
    return YES;
}

// if the custom view is not guaranteed to be in a window, the lockFocus method of the NSView class
// this method makes sure that the view is locked prior to drawing and that the context is the current one
- (void) lockFocus {
    [super lockFocus];

    NSOpenGLContext* context = self.glContext;
    if ([context view] != self) {
        // unlike NSOpenGLView custom NSView does not export a -prepareOpenGL method to override
        // therefore it must be called explicitly once the focus has been locked (won't have a valid
        // frame buffer until the focus has been locked)

        [context makeCurrentContext];

        // NOTE: if the application did not use the display link would need to implement proper pacing
        //       and use the setNeedsDisplay after drawing has been complete and front/back buffers swapped
        [self setupDisplayLink];

        // it would appear that when setting an NSView to the NSOpenGLContext it does attempt to
        // send a prepareOpenGL selector the NSView whether or not it is implemented
        [context setView:self];
    }
}

// NOTE: Apple's documentation officially states:
//       "The reshape method is not supported by the NSView class. You need to update bounds in the drawRect: method"
//
//       then who is calling reshape? seems to be coming from the NSOpenGLContext assuming that the NSView assigned
//       to it is an NSOpenGLView
- (void) drawRect:(CGRect)dirtyRect {
    // NOTE: the renderer draws on a secondary thread through the display link while the resize call
    //       occurs on the main thread hence the context lock to keep the threads in sync
    CGLLockContext([self.glContext CGLContextObj]);


    //
    // TODO: make sure that any relevant NFCamera objects get updated
    //


    // NOTE: not using dirtyRect since it will only contain the portion of the view that needs updating
    CGRect rect = [self bounds];
    [self.glRenderer resizeToRect:rect];

    // use CGSize if not supporting multiple viewports per renderer

    // if supporting multiple viewports per renderer then the renderer should own the viewport
    // and not the NFViewVolume class

    // allowing multiple viewports per renderer will most likely keep overhead lower
    // by eliminating the need for multiple NSView objects

    // would need ability to bind a NFViewVolume to a viewport

    // would need ability to resize a specified viewport


    CGLUnlockContext([self.glContext CGLContextObj]);
}

- (void) setupTiming {
    // get ticks per second and number of ticks accuracy
    //m_currHostFreq = CVGetHostClockFrequency();
    //m_minHostDelta = CVGetHostClockMinimumTimeDelta();
}

- (BOOL) acceptsFirstResponder {
    return YES;
}

//- (BOOL) canBecomeKeyView {
//    return YES;
//}

- (void) keyDown:(NSEvent *)theEvent {
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    switch (key) {
        case 'w':
            [self.camera setState:kCameraStateActFwd];
            break;

        case 's':
            [self.camera setState:kCameraStateActBack];
            break;

        case 'a':
            [self.camera setState:kCameraStateActRight];
            break;

        case 'd':
            [self.camera setState:kCameraStateActLeft];
            break;

            // angular delta values in radians (0.004998, -0.004009)

        case 'j': {

            static float angularDelta = 0.0f;
            angularDelta += 0.05f;


            // NOTE: left/right rotation is around the z axis
            //       up/down rotation is around the x axis


            //GLKQuaternion quatRotation = GLKQuaternionMakeWithAngleAndAxis(angularDelta, 0.0f, 0.0f, 1.0f);

            //float quatAngle = GLKQuaternionAngle(quatRotation);
            //NSLog(@"quaternion angle in radians: %f", quatAngle);



            //GLKVector4 temp = GLKVector4Add(self.camera.position, self.camera.target);

            //GLKVector4 temp = GLKVector4Subtract(self.camera.position, self.camera.target);
            GLKVector4 temp = GLKVector4Subtract(self.camera.target, self.camera.position);



            //self.camera.target = GLKQuaternionRotateVector4(quatRotation, temp);



            //
            // TODO: need to collapse the view volume into the camera class, there is nothing to gain
            //       from trying to make them two separate modules and only increases complexity of use
            //

            

            //
            // TODO: translate camera to origin, then rotate, and finally translate back
            //

            GLKMatrix4 rotationMat = GLKMatrix4MakeRotation(angularDelta, 0.0f, 0.0f, 1.0f);
            self.camera.target = GLKMatrix4MultiplyVector4(rotationMat, temp);


            NSLog(@"modified camera target (%f, %f, %f)", self.camera.target.v[0], self.camera.target.v[1], self.camera.target.v[2]);

        } break;


        case 'k':
            //
            // TODO: rotate camera target vector by -0.005
            //
            break;

        default:
            break;
    }
}

- (void) keyUp:(NSEvent *)theEvent {
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    switch (key) {
        case 'w':
            [self.camera setState:kCameraStateNilFwd];
            break;

        case 's':
            [self.camera setState:kCameraStateNilBack];
            break;

        case 'a':
            [self.camera setState:kCameraStateNilRight];
            break;

        case 'd':
            [self.camera setState:kCameraStateNilLeft];
            break;

        case 'o':
            [self.camera resetTarget];
            break;

        case 'p':
            [self.camera resetPosition];
            [self.camera resetTarget];
            break;

        default:
            break;
    }
}

- (void) mouseDown:(NSEvent *)theEvent {

    NSPoint location = [self convertPointFromBacking:[theEvent locationInWindow]];
    NSLog(@"NFView mouse down at (%f, %f)", location.x, location.y);

    //
    // TODO: use this code when there is more than one view for the window
    //
    //NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    //BOOL isInside = [self mouse:mouseLoc inRect:[self bounds]];
    //NSLog(@"inside = %d, mouse location (%f, %f)", isInside, mouseLoc.x, mouseLoc.y);

    //
    // TODO: currently the cursor movement is based off of the full display (and assuming
    //       only one display), it should be updated to handle movement within a window/view
    //

    self.onLeftEdge = NO;
    self.onRightEdge = NO;
    self.onUpperEdge = NO;
    self.onLowerEdge = NO;

    //
    // TODO: will want to better handle the CG display i.e should get the display
    //       that the window is currently occupying (and account for a window that
    //       spans multiple displays)
    //
    //CGDirectDisplayID nullDisplay = kCGNullDirectDisplay;

    CGDirectDisplayID displayId = CGMainDisplayID();

    //
    // TODO: cache the current mouse cursor location and then on mouse up warp
    //       the mouse position to the cached location
    //

    NSPoint centerPoint;
    centerPoint.x = CGDisplayPixelsWide(displayId) / 2;
    centerPoint.y = CGDisplayPixelsHigh(displayId) / 2;
    self.mouseLocation = centerPoint;

    CGWarpMouseCursorPosition(centerPoint);
    CGDisplayHideCursor(displayId);

    //
    //
    //
}

- (void) mouseUp:(NSEvent *)theEvent {

    //NSPoint location = [self convertPointFromBacking:[theEvent locationInWindow]];
    //NSLog(@"NFView received a mouseUp event at location (%f, %f)", location.x, location.y);

    NSLog(@"NFView received a mouseUp event");

    CGDisplayShowCursor(CGMainDisplayID());

}

- (void) mouseDragged:(NSEvent *)theEvent {
    //NSPoint location = [theEvent locationInWindow];
    //NSLog(@"NFView received a mouseDragged event at location (%f, %f)", location.x, location.y);

    //
    // TODO: check if location is at edge of screen and if true then increment angle by fixed amount
    //       (should most likely increment by the last angular increment
    //

    CGPoint point = CGEventGetLocation([theEvent CGEvent]);
    //NSLog(@"CG event point (%f, %f)", point.x, point.y);

    CGDirectDisplayID displayId = CGMainDisplayID();

    NSPoint centerPoint;
    centerPoint.x = CGDisplayPixelsWide(displayId) / 2;
    centerPoint.y = CGDisplayPixelsHigh(displayId) / 2;

    // these values will be normalized to [-0.5f, 0.5f] i.e. -45.0 to 45.0

    float normalizedX0 = (self.mouseLocation.x - centerPoint.x) / CGDisplayPixelsWide(displayId);
    float normalizedY0 = (self.mouseLocation.y - centerPoint.y) / CGDisplayPixelsHigh(displayId);

    float normalizedX1 = (point.x - centerPoint.x) / CGDisplayPixelsWide(displayId);
    float normalizedY1 = (point.y - centerPoint.y) / CGDisplayPixelsHigh(displayId);

    //
    // TODO: would it make sense to map the normalized values into the NFCamera's vertical and
    //       horizontal field of view
    //

    float angleX0 = asin(normalizedX0);
    float angleY0 = asin(normalizedY0);

    float angleX1 = asin(normalizedX1);
    float angleY1 = asin(normalizedY1);

    float angularDeltaX = angleX1 - angleX0;
    float angularDeltaY = angleY1 - angleY0;

    //NSLog(@"new point angles (%f, %f) old point angles (%f, %f)", angleX0 * 180.0f/M_PI, angleY0 * 180.0f/M_PI,
    //      angleX1 * 180.0f/M_PI, angleY1 * 180.0f/M_PI);

    NSLog(@"angular delta values (%f, %f)", angularDeltaX, angularDeltaY);

    //
    // TODO: need to determine best and most accurate way of converting the angular distance
    //       into a rotation to apply to the camera's target vector
    //
    //GLKMatrix4 rotationMatX = GLKMatrix4RotateX(GLKMatrix4Identity, angularDeltaX);
    //GLKMatrix4 rotationMatY = GLKMatrix4RotateY(GLKMatrix4Identity, angularDeltaY);

    //GLKQuaternion quatRotationX = GLKQuaternionMakeWithAngleAndVector3Axis(angularDeltaX, GLKVector3Make(1.0f, 0.0f, 0.0f));
    //GLKQuaternion quatRotationY = GLKQuaternionMakeWithAngleAndVector3Axis(angularDeltaY, GLKVector3Make(0.0f, 1.0f, 0.0f));

    // NOTE: NSPoint is a typedef of CGPoint so this is a safe cast to make
    self.mouseLocation = (NSPoint)point;
}

- (void) setupOpenGL {
    //
    // NOTE: requesting an NSOpenGLProfileVersion3_2Core will create an OpenGL 4.1 context
    //
    NSOpenGLPixelFormatAttribute attribs[] = {
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)24, // should give an 8-bit stencil buffer
        NSOpenGLPFAOpenGLProfile, (NSOpenGLPixelFormatAttribute)NSOpenGLProfileVersion3_2Core,
        (NSOpenGLPixelFormatAttribute)0
    };

    NSOpenGLPixelFormat *pf = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attribs] autorelease];
    NSAssert(pf != nil, @"Error: could not create an OpenGL compatible pixel format");

    NSOpenGLContext *context = [[[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil] autorelease];
    NSAssert(context != nil, @"Failed to create an OpenGL context");

    self.pixelFormat = pf;
    self.glContext = context;
    [self.glContext makeCurrentContext];

    // synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [self.glContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];

    //
    // TODO: determine whether or not to use CGL multithreading or not (doesn't appear
    //       to work too well when using the display link but should be revisited
    //       when manually using window/thread/pacing instead of the display link and XIB)
    //
#define ENABLE_MULTITHREADING 0

#if ENABLE_MULTITHREADING
    CGLError err = 0;
    CGLContextObj cglContext = [self.glContext CGLContextObj];

    // enable multithreading
    err = CGLEnable(cglContext, kCGLCEMPEngine);
    if (err != kCGLNoError) {
        NSLog(@"failed to enable multithreading (kCGLCEMPEngine)");
    }
#endif
}

- (void) initRenderer {
    [self.glContext makeCurrentContext];
    self.glRenderer = [[[NFRenderer alloc] init] autorelease];
    NSAssert(self.glRenderer != nil, @"Failed to initialize and create NSGLRenderer");


    //
    // TODO: should move the camera ownership into NFSimulation (or where ever the main update loop will be)
    //
    float nearPlane = 1.0f;
    float farPlane = 100.0f;

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    GLKMatrix4 projection = GLKMatrix4MakePerspective(M_PI_4, width / height, nearPlane, farPlane);

    self.camera = [[[NFCamera alloc] init] autorelease];

    self.camera.width = (NSUInteger)width;
    self.camera.height = (NSUInteger)height;

    self.camera.vFOV = (float) M_PI_4;

    self.camera.position = GLKVector4Make(0.0f, 2.0f, 4.0f, 1.0f);
    self.camera.target = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.camera.up = GLKVector4Make(0.0f, 1.0f, 0.0f, 1.0f);


    [self.camera setProjectionMatrix:projection];
    //
    //
    //
}

- (void) setupDisplayLink {
    CVReturn rv;

    // create a display link capable of being used with all active displays

    //
    // TODO: get working with getter (probably can't as getter is returing by value), in order
    //       for this to work will need to make the display link a class member instead of a
    //       property
    //
    //rv = CVDisplayLinkCreateWithActiveCGDisplays(&(self.displayLink));
    rv = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);

    NSAssert(rv == kCVReturnSuccess, @"Failed to create display link with active display");

    // set the renderer output callback function
    rv = CVDisplayLinkSetOutputCallback(self.displayLink, &displayLinkCallback, self);
    NSAssert(rv == kCVReturnSuccess, @"Failed to set display link callback");

    // convert NSGL objects to CGL objects
    CGLContextObj cglContext = [self.glContext CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [self.pixelFormat CGLPixelFormatObj];

    // set the display link for the current OpenGL context
    rv = CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(self.displayLink, cglContext, cglPixelFormat);
    NSAssert(rv == kCVReturnSuccess, @"Failed to set display link OpenGL context");

    // activate the display link
    rv = CVDisplayLinkStart(self.displayLink);
    NSAssert(rv == kCVReturnSuccess, @"Failed to start display link");
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime {
    // there is no autorelease pool when this method is called because it will be called from a background thread
    // it's important to create one or you will leak objects
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // TODO: is this faster than or an alternative to locking the CGL context ??
/*
    if ([self lockFocusIfCanDraw]) {
        // update frame
        [self unlockFocus];
    }
*/

    //
    // TODO: need to follow Apple documentation on how to set this all up
    //

    // TODO: only make current once and then perform check to is if still current
    [self.glContext makeCurrentContext];

    // when resizing the view, -reshape is called automatically on the main thread
    // add a mutex around to avoid the threads accessing the context simultaneously	when resizing
    CGLLockContext([self.glContext CGLContextObj]);


    //
    // TODO: run the scene simulation/step on another thread and draw the latest processed scene (once
    //       the event system is in place and working)
    //

    // "step scene" with lastest time delta
    //
    // TODO: get ride of hardcoded value of 16 ms
    //
    [self.camera step:16000];

    [self.glRenderer updateFrameWithTime:outputTime withViewMatrix:[self.camera getViewMatrix]
                          withProjection:[self.camera getProjectionMatrix]];

    // perform drawing code
    [self.glRenderer renderFrame];

    // swap front and back buffers
    CGLFlushDrawable([self.glContext CGLContextObj]);
    CGLUnlockContext([self.glContext CGLContextObj]);

    //
    // TODO: measure the frame rate and display as FPS and a running average of us per frame
    //       (try 10 frame running average and display as ms nn.nnn)
    //

    //[pool release];
    return kCVReturnSuccess;
}

- (void) surfaceNeedsUpdate:(NSNotification *)notification {
    // let NSOpenGLContext handle screen selection after resize/move
    [self.glContext update];
}

@end
