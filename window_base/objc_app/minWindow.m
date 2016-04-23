//
//  minWindow.m
//  objc_app
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//


// clang -Wall minWindow.m -fobjc-arc -framework Cocoa -x objective-c -o objc_app

#import <Cocoa/Cocoa.h>



@interface NFApplication : NSApplication
{
    BOOL shouldKeepRunning;
}

- (void) run;
- (void) terminate:(id)sender;

//
// TODO: override requestUserAttention method to prevent app icon from bouncing in the dock
//

@end


@implementation NFApplication

- (void) run {
    NSLog(@"NFApplication run method called");

/*
    [[NSNotificationCenter defaultCenter]
        postNotificationName:NSApplicationWillFinishLaunchingNotification object:NSApp];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:NSApplicationDidFinishLaunchingNotification object:NSApp];
*/

    @autoreleasepool {
        // finishLaunching method will activate the app, open any files specified by the NSOpen
        // user default, and unhighlight the app's icon (will also post willFinish and didFinish
        // notifications)
        [self finishLaunching];
    }

    shouldKeepRunning = YES;

    while(shouldKeepRunning) {
        @autoreleasepool {
            NSEvent *event = [self nextEventMatchingMask:NSAnyEventMask
                untilDate:[NSDate distantFuture] inMode:NSDefaultRunLoopMode dequeue:YES];

            [self sendEvent:event];
            [self updateWindows];
        }
    };
}

- (void) terminate:(id)sender {
    //
    // TODO: most likely don't need to call parent class terminate but should
    //       double check with all the documentation to be sure
    //
    [super terminate:sender];
    
    shouldKeepRunning = NO;
}

@end


@interface NFView : NSView

- (instancetype) initWithFrame:(NSRect)frame;
- (instancetype) initWithCoder:(NSCoder*)coder;

- (void) awakeFromNib;

- (void) insertText:(id)insertString;
- (void) keyDown:(NSEvent *)theEvent;

@end

@implementation NFView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        //[self commonInit];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        //[self commonInit];
    }
    return self;
}

- (void) awakeFromNib {
    NSLog(@"awakeFromNib should not be getting called");
}

- (void) insertText:(id)insertString {
    NSAssert([insertString isKindOfClass:[NSString class]], @"insertText called with an id that is not a string");
    NSString* string = (NSString*)insertString;
    NSLog(@"%@", string);
}

- (void) keyDown:(NSEvent *)theEvent {
    [self interpretKeyEvents:[NSArray arrayWithObjects:theEvent, nil]];
}

@end


@interface ApplicationDelegate : NSObject <NSApplicationDelegate>

//
// TODO: should have a weak reference to the NFApplicationObject and start the application simulation loop
//

//
// TODO: should move the window (as a weak reference) to the WindowDelegate and create
//       the view and menu there
//

@property (nonatomic, weak) NFApplication* application;

@property (nonatomic, strong) NSWindow* window;
@property (nonatomic, strong) NFView* view;

- (instancetype) initWithWindow:(NSWindow*)window;
- (instancetype) initWithApplication:(NFApplication*)application;

- (void) applicationDidFinishLaunching:(NSNotification*)notification;

@end

@implementation ApplicationDelegate

@synthesize application = _application;

@synthesize window = _window;
@synthesize view = _view;

- (instancetype) initWithWindow:(NSWindow*)window {
    self = [super init];
    if (self != nil) {
        _window = window;
        _view = [[NFView alloc] initWithFrame:_window.contentView.frame];
        [_window.contentView addSubview:_view];
    }
    return self;
}


- (instancetype) initWithApplication:(NFApplication*)application {
    self = [super init];
    if (self != nil) {
        _application = application;
    }
    return self;
}


/*
- (void) applicationWillFinishLaunching:(NSNotification*)notification {
    NSLog(@"application will finish launching");
}
*/

- (void) applicationDidFinishLaunching:(NSNotification*)notification {

    //
    // TODO: monitor all events and determine which will need to be handled when manually
    //       handling the event loop
    //

    id evObj = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {
        //
        // TODO: send event data to desired method based on type
        //
        if(event.type==NSKeyDown) {
            NSLog(@"key down event occured");
        }    
        return event;
    }];
    NSAssert(evObj != nil, @"event handler object is nil");
    
    // NOTE: application will get event before view
    [self.window makeFirstResponder:self.view];


    [NSApp activateIgnoringOtherApps:YES];

    NSLog(@"application did finish launching");
}

@end


@interface WindowDelegate : NSObject <NSWindowDelegate>
- (void) windowWillClose:(NSNotification*)notification;
@end

@implementation WindowDelegate
- (void) windowWillClose:(NSNotification*)notification {
    NSLog(@"window will close");
}
@end



int main (int argc, char* argv[]) {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    Class principalClass = NSClassFromString([infoDictionary objectForKey:@"NSPrincipalClass"]);


    //NSApplication *applicationObject = [principalClass sharedApplication];
    NFApplication *applicationObject = [principalClass sharedApplication];

    [applicationObject setActivationPolicy:NSApplicationActivationPolicyRegular];


    NSString* appName = [[NSProcessInfo processInfo] processName];



    NSMenu* menubar = [[NSMenu alloc] init];
    NSMenuItem* appMenuItem = [[NSMenuItem alloc] init];

    [menubar addItem:appMenuItem];

    NSMenu* appMenu = [[NSMenu alloc] init];
    NSMenuItem* quitMenuItem = [[NSMenuItem alloc] initWithTitle:[@"Quit " stringByAppendingString:appName]
        action:@selector(terminate:) keyEquivalent:@"q"];

    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];
    
    [applicationObject setMainMenu:menubar];



    NSWindow* window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 200, 200)
        styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];

    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window setTitle:appName];
    [window makeKeyAndOrderFront:nil];


    //
    // TODO: rename WindowDelegate and ApplicationDelegate to NFWindowDelegate and NFApplicationDelegate
    //
    WindowDelegate* windowDelegate = [[WindowDelegate alloc] init];
    [window setDelegate:windowDelegate];

    ApplicationDelegate* applicationDelegate = [[ApplicationDelegate alloc] initWithWindow:window];
    [applicationObject setDelegate:applicationDelegate];



    if ([applicationObject respondsToSelector:@selector(run)]) {
        [applicationObject performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:YES];
    }


    // here just in case something unexpected causes the run loop to exit
    [applicationObject terminate:nil];

    return 0;
}
