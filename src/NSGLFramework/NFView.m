//
//  NFView.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

// application headers
#import "NFView.h"
#import "NFRenderer.h"

// Cocoa headers
#import <QuartzCore/CVDisplayLink.h>


//
// TODO: NFCamera should only temporarily be used by NFView, should be moved
//       to the simulation/application module
//
#import "NFCamera.h"


static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now,
                                    const CVTimeStamp* outputTime, CVOptionFlags flagsIn,
                                    CVOptionFlags* flagsOut, void* displayLinkContext);

@interface NFView() {
    //double m_currHostFreq; // ticks per second
    //uint32_t m_minHostDelta; // number of ticks accuracy


    //
    // TODO: perform more testing before promoting tracking area to a property
    //
    NSTrackingArea* m_trackingArea;


    //
    // TODO: create an NFInputController class and move these properties and the
    //       mouse and keyboard control into the class
    //
    NSPoint m_mouseLocation;
    //BOOL m_onLeftEdge;
    //BOOL m_onRightEdge;
    //BOOL m_onUpperEdge;
    //BOOL m_onLowerEdge;


    //
    // TODO: these should be made properties of the input controller
    //
    float m_horizontalAngle;
    float m_verticalAngle;
    BOOL m_input;

}

@property (nonatomic, assign) CVDisplayLinkRef displayLink;

//
// TODO: support full display rendering with CGL for "game" mode
//       and add support for OS X fullscreen mode
//
@property (nonatomic, retain) NSOpenGLContext *glContext;
@property (nonatomic, retain) NSOpenGLPixelFormat *pixelFormat;

@property (nonatomic, retain) NFRenderer *glRenderer;
@property (nonatomic, retain) NFViewVolume *viewVolume;
@property (nonatomic, retain) NFCamera *camera;

- (void) execStartupSequence;
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
@synthesize viewVolume = _viewVolume;
@synthesize camera = _camera;

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now,
                                    const CVTimeStamp* outputTime, CVOptionFlags flagsIn,
                                    CVOptionFlags* flagsOut, void* displayLinkContext) {
    CVReturn result = [(NFView*)displayLinkContext getFrameForTime:outputTime];
    assert(result == kCVReturnSuccess);
    return result;
}

// initWithFrame is the initializer used when if object is instantiated in code
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) {
        NSLog(@"failed initWithFrame");
    }
    else {
        [self execStartupSequence];
    }
    return self;
}

// initWithCoder is the initializer called for archived objects, as objects stored in nibs
// are archived objects, this initializer is used when loading object from a nib
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self == nil) {
        NSLog(@"failed initWithCode");
    }
    else {
        [self execStartupSequence];
    }
    return self;
}

- (void) execStartupSequence {

    m_input = NO;

    [self setupTiming];
    [self setupOpenGL];
    [self initRenderer];

    //[self setupTrackingArea];
}


//
// TODO: may need to use a tracking area, identify under which circumstances it is needed
//       (will definitely be needed for mouse entered/exited events)
//

// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/EventOverview/MouseTrackingEvents/MouseTrackingEvents.html
// https://developer.apple.com/library/mac/samplecode/TrackIt/Introduction/Intro.html#//apple_ref/doc/uid/DTS10004139-Intro-DontLinkElementID_2


// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/WinPanel/Introduction.html#//apple_ref/doc/uid/10000031i
// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/EventOverview/HandlingMouseEvents/HandlingMouseEvents.html


- (void) setupTrackingArea {
    [self clearTrackingArea];

    NSTrackingAreaOptions trackingOptions = NSTrackingCursorUpdate | NSTrackingEnabledDuringMouseDrag |
        NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp;

    m_trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:trackingOptions owner:self userInfo:nil];
    [self addTrackingArea:m_trackingArea];
}

- (void) clearTrackingArea {
    if (m_trackingArea) {
        [self removeTrackingArea:m_trackingArea];
        [m_trackingArea release];
        m_trackingArea = nil;
    }
}


- (void) dealloc {
    //
    // TODO: make sure dealloc is cleaning everything up (i.e. do events need to be unregisterd etc.)
    //

    //[self clearTrackingArea];

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

    // setup to handle mouse moved events
    [[self window] makeFirstResponder:self];
    [[self window] setAcceptsMouseMovedEvents:YES];
}

// method is called only once after the OpenGL context is made the current context, subclasses that
// implement this method can use it to configure the OpenGL state in preparation for drawing
- (void) prepareOpenGL {
    //NSLog(@"prepareOpenGL");
}

//
// TODO: setup some kind of catch all method to attempt to see who is trying to call what
//       on the NFView (i.e. self)
//

// drawing performance will be faster when view object is opaque (view object will be
// responsible for filling its bounding rectanlge
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

// enusre that view is first object in the responder chain to be sent key events and action messages
- (BOOL) acceptsFirstResponder {
    return YES;
}

// ensure full keyboard access behavior for view
- (BOOL) canBecomeKeyView {
    return YES;
}

// default is NO, return YES to be set a mouseDown message for an initial mouse-down event
//
// TODO: determine if this is needed to capture mouseMoved events
//
//- (BOOL) acceptsFirstMouse:(NSEvent *)theEvent {
//    return YES;
//}

- (void) keyDown:(NSEvent *)theEvent {
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    switch (key) {
        case 'w':
            [self.camera setTranslationState:kCameraStateActFwd];
            break;

        case 's':
            [self.camera setTranslationState:kCameraStateActBack];
            break;

        case 'a':
            [self.camera setTranslationState:kCameraStateActRight];
            break;

        case 'd':
            [self.camera setTranslationState:kCameraStateActLeft];
            break;

        default:
            break;
    }
}

- (void) keyUp:(NSEvent *)theEvent {
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    switch (key) {
        case 'w':
            [self.camera setTranslationState:kCameraStateNilFwd];
            break;

        case 's':
            [self.camera setTranslationState:kCameraStateNilBack];
            break;

        case 'a':
            [self.camera setTranslationState:kCameraStateNilRight];
            break;

        case 'd':
            [self.camera setTranslationState:kCameraStateNilLeft];
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

//
// TODO: use mouse wheel and a key to increase/decrease to FOV of the camera
//

- (void) mouseDown:(NSEvent *)theEvent {
    //
    // NOTE: use this code when there is more than one view for the window
    //
    //NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    //BOOL isInside = [self mouse:mouseLoc inRect:[self bounds]];
    //NSLog(@"inside = %d, mouse location (%f, %f)", isInside, mouseLoc.x, mouseLoc.y);

    //
    // TODO: currently the cursor movement is based off of the full display (and assuming
    //       only one display), it should be updated to handle movement within a window/view
    //

    //m_onLeftEdge = NO;
    //m_onRightEdge = NO;
    //m_onUpperEdge = NO;
    //m_onLowerEdge = NO;

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
    centerPoint.x = CGDisplayPixelsWide(displayId) / 2.0f;
    centerPoint.y = CGDisplayPixelsHigh(displayId) / 2.0f;

    m_mouseLocation = centerPoint;

    CGWarpMouseCursorPosition(centerPoint);
    CGDisplayHideCursor(displayId);
}

- (void) mouseUp:(NSEvent *)theEvent {

    CGDisplayShowCursor(CGMainDisplayID());

    //
    // TODO: warp mouse location to where the click originated
    //
}

- (void) mouseMoved:(NSEvent *)theEvent {
/*
    static const float ROTATION_GAIN = 0.008f;
    //static const float MOVEMENT_GAIN = 2.0f;

    GLKVector2 rotationDelta;
    rotationDelta.v[0] = [theEvent deltaX] * ROTATION_GAIN;
    rotationDelta.v[1] = [theEvent deltaY] * ROTATION_GAIN;

    m_horizontalAngle += rotationDelta.v[0];
    m_verticalAngle -= rotationDelta.v[1];

    // limit pitch to straight up or straight down
    float limit = M_PI / 2.0f - 0.01f;
    m_verticalAngle = MAX(-limit, m_verticalAngle);
    m_verticalAngle = MIN(+limit, m_verticalAngle);

    // keep longitude in sane range by wrapping
    if (m_horizontalAngle > M_PI) {
        m_horizontalAngle -= M_PI * 2.0f;
    }
    else if (m_horizontalAngle < -M_PI) {
        m_horizontalAngle += M_PI * 2.0f;
    }
*/
}


// NOTE: these will only be active when the view has a tracking area setup
- (void) mouseEntered:(NSEvent *)theEvent {
    NSLog(@"mouseEntered NFView");
}

- (void) mouseExited:(NSEvent *)theEvent {
    NSLog(@"mouseExited NFView");
}


- (void) mouseDragged:(NSEvent *)theEvent {
    //NSPoint location = [theEvent locationInWindow];
    //NSLog(@"NFView received a mouseDragged event at location (%f, %f)", location.x, location.y);

    //
    // TODO: check if location is at edge of screen and if true then increment angle by fixed amount
    //       (should most likely increment by the last angular increment
    //

    CGPoint point = CGEventGetLocation([theEvent CGEvent]);

    CGPoint centerPoint;
    CGDirectDisplayID displayId = CGMainDisplayID();
    centerPoint.x = CGDisplayPixelsWide(displayId) / 2.0f;
    centerPoint.y = CGDisplayPixelsHigh(displayId) / 2.0f;

    // x - red
    // y - green
    // z - blue

    // these values will be normalized to [-0.5f, 0.5f] i.e. -45.0 to 45.0

    float normalizedX0 = (m_mouseLocation.x - centerPoint.x) / CGDisplayPixelsWide(displayId);
    float normalizedY0 = (m_mouseLocation.y - centerPoint.y) / CGDisplayPixelsHigh(displayId);

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

    m_horizontalAngle -= angularDeltaX;
    m_verticalAngle -= angularDeltaY;

    // limit pitch to straight up or straight down
    float limit = M_PI_2 - 0.01f;
    m_verticalAngle = MAX(-limit, m_verticalAngle);
    m_verticalAngle = MIN(+limit, m_verticalAngle);

    // keep longitude in sane range by wrapping
    if (m_horizontalAngle > M_PI) {
        m_horizontalAngle -= M_PI * 2.0f;
    }
    else if (m_horizontalAngle < -M_PI) {
        m_horizontalAngle += M_PI * 2.0f;
    }

    m_input = YES;

    // NOTE: NSPoint is a typedef of CGPoint so this is a safe cast to make
    m_mouseLocation = (NSPoint)point;
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
    self.viewVolume = [[[NFViewVolume alloc] init] autorelease];
    self.camera = [[[NFCamera alloc] init] autorelease];


    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    [self.viewVolume setShapeWithVerticalFOV:(float)M_PI_4 withAspectRatio:(width/height)
                                withNearDist:1.0f withFarDist:100.0f];


    GLKVector3 eye = GLKVector3Make(4.0f, 2.0f, 4.0f);

    //GLKVector3 eye = GLKVector3Make(4.0f, 0.0f, 4.0f);
    //GLKVector3 eye = GLKVector3Make(0.0f, 4.0f, 4.0f);

    GLKVector3 look = GLKVector3Make(0.0f, 0.0f, 0.0f);
    GLKVector3 up = GLKVector3Make(0.0f, 1.0f, 0.0f);

    //[m_camera setEyePosition:eye withLookVector:look withUpVector:up];
    [self.camera setEyePosition:eye withLookVector:look withUpVector:up];

    //
    // TODO: need to calculate the starting angles based on the eye, look, and up vectors
    //       should also extract horizontal and vertical angle from camera class since they
    //       can be changed with setViewParams method (or remove the setViewParams method and
    //       replace with translate and lookAt methods - would still need to determine
    //       horizontal and vertical angles from both methods)
    //

    // horizontal angle should just be the angle between the x,z points
    // vertical angle should just be the angle between the y,z points

    //m_horizontalAngle = M_PI;    // look to -Z
    //m_horizontalAngle = -M_PI;   // look to -Z
    //m_horizontalAngle = 0.0f;    // look to +Z

    //m_verticalAngle = M_PI_2 - 0.01f;   // look straight up
    //m_verticalAngle = -M_PI_2 + 0.01f;  // look straight down
    //m_verticalAngle = 0.0f;             // look at horizon

    m_verticalAngle = -M_PI_4 / 2.0f;
    m_horizontalAngle = -M_PI + M_PI_4;

    m_input = YES;
}

- (void) setupDisplayLink {
    CVReturn rv;

    // create a display link capable of being used with all active displays
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

    //static float secs = 0.0; // elapsed time
    static uint64_t prevVideoTime = 0;

    //
    // TODO: if debug check time stamp flags against kCVTimeStampVideoHostTimeValid
    //

    //NSLog(@"update period per second: %lld", outputTime->videoTimeScale / outputTime->videoRefreshPeriod);

    // update rate 59 hertz
    // 0.016699 seconds
    // 16.600 ms

    NSUInteger msElapsed = 0;
    NSUInteger usElapsed = 0;

    if (prevVideoTime != 0) {
        //secs += (outputTime->videoTime - prevVideoTime) / (float) outputTime->videoTimeScale;
        //NSLog(@"secs: %f", secs);

        // step is floating point seconds
        float step = (outputTime->videoTime - prevVideoTime) / (float) outputTime->videoTimeScale;

        //
        // TODO: make constants for convert seconds to milli/micro seconds
        //
        msElapsed = (NSUInteger)(step * 1000.0f);
        usElapsed = (NSUInteger)(step * 1000.0f * 1000.0f);
    }

    prevVideoTime = outputTime->videoTime;



    // there is no autorelease pool when this method is called because it will be called from a background thread
    // it's important to create one or you will leak objects
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    //
    // TODO: is this faster than or an alternative to locking the CGL context ??
    //
/*
    if ([self lockFocusIfCanDraw]) {
        // update frame
        [self unlockFocus];
    }
*/

    //
    // TODO: only make current once and then perform check to is if still current
    //
    [self.glContext makeCurrentContext];

    // when resizing the view, reshape is called automatically on the main thread
    // add a mutex around to avoid the threads accessing the context simultaneously	when resizing
    CGLLockContext([self.glContext CGLContextObj]);


    //
    // TODO: run the scene simulation/step on another thread and draw the latest processed scene (once
    //       the event system is in place and working)
    //

    // step scene/simulation with lastest time delta
    [self.camera step:msElapsed];


    if (m_input) {
        m_input = NO;
        [self.camera setLookHorizontalAngle:m_horizontalAngle verticalAngle:m_verticalAngle];
    }

    GLKMatrix4 viewMat = self.camera.viewMatrix;
    GLKMatrix4 projMat = self.viewVolume.projection;

    
    //
    // TODO: rather than pass in the outputTime pass in the msElapsed
    //
    [self.glRenderer updateFrameWithTime:outputTime withViewMatrix:viewMat withProjection:projMat];



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
