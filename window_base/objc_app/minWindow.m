//
//  minWindow.m
//  objc_app
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//


#import <Cocoa/Cocoa.h>

/*
- (void) run
{

    //[self finishLaunching];

    BOOL shouldKeepRunning = YES;
    while (shouldKeepRunning)
    {

        @autoreleasepool {

            //
            // TODO: will this nicely block without just spinning on the CPU ??
            //       (it might appear that using [NSDate distantFuture] will allow it to block nicely)
            //
            NSEvent *event = [self nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantFuture]
                inMode:NSDefaultRunLoopMode dequeue:YES];

            //[self sendEvent:event];
            //[self updateWindows];
 
        }
    }

    [pool release];
}
*/

// clang minWindow.m -framework Cocoa -x objective-c -o MinimalistCocoaApp


int main ()
{
    [[NSAutoreleasePool alloc] init];
    
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    id menubar = [[[NSMenu alloc] init] autorelease];
    id appMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [menubar addItem:appMenuItem];
    [NSApp setMainMenu:menubar];

    id appMenu = [[[NSMenu alloc] init] autorelease];
    id appName = [[NSProcessInfo processInfo] processName];
    
    id quitTitle = [@"Quit " stringByAppendingString:appName];
    id quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle
        action:@selector(terminate:) keyEquivalent:@"q"] autorelease];

    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];

    id window = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 200, 200)
        styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO] autorelease];

    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window setTitle:appName];
    [window makeKeyAndOrderFront:nil];

    [NSApp activateIgnoringOtherApps:YES];
    
    [NSApp run];
    
    //
    // TODO: manual message pump
    //
/*
    bool quit = false;
    while (!quit)
    {
        NSEvent *event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES];
        switch([(NSEvent *)event type])
        {
        case NSKeyDown:
            quit = true;
            break;
        default:
            [NSApp sendEvent:event];
            break;
        }
        [event release];
 
        usleep(10000);
    }
*/

    [NSApp terminate:nil];
    return 0;
}
