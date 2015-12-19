//
//  minWindow.m
//  objc_app
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//


#import <Cocoa/Cocoa.h>


// clang -Wall minWindow.m -framework Cocoa -x objective-c -o objc_app


//
// TODO: rough implementation for NFView class
//
@interface NFView : NSView

- (instancetype) initWithFrame:(NSRect)frame;
- (instancetype) initWithCoder:(NSCoder*)coder;

// insertText
// keyDown
// awakeFromNib

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
    }
    return self;
}

- (void) applicationDidFinishLaunching:(NSNotification*)notification {

    //
    // TODO: set first responder and/or register for key events as well
    //

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


int main (int argc, char* argv[])
{
    [[NSAutoreleasePool alloc] init];
    
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
    return 0;
}
