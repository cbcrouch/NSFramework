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
#import "NFCamera.h"

// Cocoa headers
#import <QuartzCore/CVDisplayLink.h>

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

    //
    // TODO: make display link a private member versus property (should really do this
    //       for any/all non-objects to avoid the issue of having to pass something by
    //       reference since the getter will only return by value) <- verify last statement
    //
    //CVDisplayLinkRef m_displayLink;
}

// non-object ivars
@property (nonatomic, assign) CVDisplayLinkRef displayLink;

// NOTE: only public parts of CGL API are for full screen contexts, using NSGL
@property (nonatomic, retain) NSOpenGLContext *glContext;
@property (nonatomic, retain) NSOpenGLPixelFormat *pixelFormat;

@property (nonatomic, retain) NFRenderer *glRenderer;
@property (nonatomic, retain) NFViewVolume *viewVolume;
@property (nonatomic, retain) NFCamera *camera;


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
@synthesize viewVolume = _viewVolume;
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
- (id) initWithFrame:(CGRect)frame {
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

- (id) initWithCoder:(NSCoder *)aDecoder {
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

        default:
            break;
    }
}

- (void) mouseDown:(NSEvent *)theEvent {
    //NSLog(@"NFView received a mouseDown event");
    [super mouseDown:theEvent];
}

- (void) mouseUp:(NSEvent *)theEvent {
    //NSLog(@"NFView received a mouseUp event");
    [super mouseUp:theEvent];
}

- (void) mouseDragged:(NSEvent *)theEvent {

    //NSLog(@"NFView received a mouseDragged event");

    //
    // TODO: implement arc ball
    //

    [super mouseDragged:theEvent];
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



    self.viewVolume = [[[NFViewVolume alloc] init] autorelease];

    float nearPlane = 1.0f;
    float farPlane = 100.0f;

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    GLKMatrix4 projection = GLKMatrix4MakePerspective(M_PI_4, width / height, nearPlane, farPlane);
    [self.viewVolume pushProjectionMatrix:projection];

    self.viewVolume.nearPlane = 1.0f;
    self.viewVolume.farPlane = 100.0f;



    //
    // TODO: should move the camera ownership into NFSimulation (or where ever the main update loop will be)
    //
    self.camera = [[[NFCamera alloc] init] autorelease];

    [self.viewVolume setActiveCamera:self.camera];
    self.camera.observer = self.viewVolume;

    self.camera.width = (NSUInteger)width;
    self.camera.height = (NSUInteger)height;

    self.camera.vFOV = (float) M_PI_4;

    self.camera.position = GLKVector4Make(0.0f, 2.0f, 4.0f, 1.0f);
    self.camera.target = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.camera.up = GLKVector4Make(0.0f, 1.0f, 0.0f, 1.0f);
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
    // TODO: currently passing a hard value of 16 ms
    //
    [self.camera step:16000];

    [self.glRenderer updateFrameWithTime:outputTime withViewVolume:self.viewVolume];


    //
    // TODO: rendering should be performed on a scene with a camera and assigned to a viewport
    //

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
