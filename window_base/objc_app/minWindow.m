//
//  minWindow.m
//  objc_app
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//


// clang -Wall minWindow.m -framework Cocoa -x objective-c -o objc_app


#import <Cocoa/Cocoa.h>


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

@property (nonatomic, retain) NSWindow* window;
@property (nonatomic, retain) NFView* view;

- (instancetype) initWithWindow:(NSWindow*)window;
- (void) applicationDidFinishLaunching:(NSNotification*)notification;

@end

@implementation ApplicationDelegate

@synthesize window = _window;
@synthesize view = _view;

- (instancetype) initWithWindow:(NSWindow*)window {
    self = [super init];
    if (self != nil) {
        _window = window;
        _view = [[[NFView alloc] initWithFrame:_window.contentView.frame] autorelease];
        [_window.contentView addSubview:_view];
    }
    return self;
}

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



@interface NFApplication : NSApplication
{
    BOOL shouldKeepRunning;
}

- (void) run;
- (void) terminate:(id)sender;

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
    [[NSNotificationCenter defaultCenter]
        postNotificationName:NSApplicationWillFinishLaunchingNotification object:self];


    //
    // TODO: this method is the key to hooking everything up, need to pull it apart and
    //       find out if it can be manually implemented
    //
    [self finishLaunching];


    [[NSNotificationCenter defaultCenter]
        postNotificationName:NSApplicationDidFinishLaunchingNotification object:self];

    shouldKeepRunning = YES;
    
    while(shouldKeepRunning) {
        NSEvent *event = [self nextEventMatchingMask:NSAnyEventMask
            untilDate:[NSDate distantFuture] inMode:NSDefaultRunLoopMode dequeue:YES];

        [self sendEvent:event];
        [self updateWindows];
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


int main (int argc, char* argv[]) {

    [[NSAutoreleasePool alloc] init];

    
#define USE_MANUAL_EVENT_LOOP 1

//
//
//
#if USE_MANUAL_EVENT_LOOP

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    Class principalClass = NSClassFromString([infoDictionary objectForKey:@"NSPrincipalClass"]);
    

    //NSApplication *applicationObject = [principalClass sharedApplication];
    NFApplication *applicationObject = [principalClass sharedApplication];
    

    [applicationObject setActivationPolicy:NSApplicationActivationPolicyRegular];

    NSMenu* menubar = [[[NSMenu alloc] init] autorelease];
    NSMenuItem* appMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [menubar addItem:appMenuItem];
    
    [applicationObject setMainMenu:menubar];


    NSMenu* appMenu = [[[NSMenu alloc] init] autorelease];
    NSString* appName = [[NSProcessInfo processInfo] processName];
    
    NSLog(@"appName: %@", appName);
    
    NSString* quitTitle = [@"Quit " stringByAppendingString:appName];
    NSMenuItem* quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle
        action:@selector(terminate:) keyEquivalent:@"q"] autorelease];

    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];

    NSWindow* window = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 200, 200)
        styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO] autorelease];

    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window setTitle:appName];
    [window makeKeyAndOrderFront:nil];

    [applicationObject activateIgnoringOtherApps:YES];
    
    WindowDelegate* windowDelegate = [[[WindowDelegate alloc] init] autorelease];
    [window setDelegate:windowDelegate];
    
    ApplicationDelegate* applicationDelegate = [[[ApplicationDelegate alloc] initWithWindow:window] autorelease];
    [applicationObject setDelegate:applicationDelegate];


    //
    // TODO: manual event loop will get a key event on Cmd-Q but does not exit application, while
    //       the NSApp event loop will handle this correctly, need to fix so works as intended
    //
    
    if ([applicationObject respondsToSelector:@selector(run)]) {
        [applicationObject performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:YES];
    }


    [applicationObject terminate:nil];

//
//
//
#else
//
//
//

    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    NSMenu* menubar = [[[NSMenu alloc] init] autorelease];
    NSMenuItem* appMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [menubar addItem:appMenuItem];
    
    [NSApp setMainMenu:menubar];

    NSMenu* appMenu = [[[NSMenu alloc] init] autorelease];
    NSString* appName = [[NSProcessInfo processInfo] processName];
    
    NSString* quitTitle = [@"Quit " stringByAppendingString:appName];
    NSMenuItem* quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle
        action:@selector(terminate:) keyEquivalent:@"q"] autorelease];

    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];

    NSWindow* window = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 200, 200)
        styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO] autorelease];

    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window setTitle:appName];
    [window makeKeyAndOrderFront:nil];

    [NSApp activateIgnoringOtherApps:YES];

    WindowDelegate* windowDelegate = [[[WindowDelegate alloc] init] autorelease];
    [window setDelegate:windowDelegate];
    
    ApplicationDelegate* applicationDelegate = [[[ApplicationDelegate alloc] initWithWindow:window] autorelease];
    [NSApp setDelegate:applicationDelegate];

    [NSApp run];

    [NSApp terminate:nil];

#endif
//
//
//

    return 0;
}
