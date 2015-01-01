//
//  AppDelegate.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //
    // TODO: insert code here to initialize your application
    //
}

//
// TODO: allow for configuring whether in "game" or "editor" mode, when in editor
//       mode this should return NO and disable the renderer when no window is open,
//       and in game mode should return YES so the application can't run without a
//       window open
//
-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
    return YES;
}

@end
