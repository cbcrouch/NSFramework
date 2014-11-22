//
//  NFView.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//


#import <Foundation/Foundation.h>


//#define SYNC_SWAP_INTERVAL 1
//#define DISABLE_VERTICAL_SYNC 0

@interface NFView : NSView

- (id) initWithFrame:(CGRect)frame;
- (id) initWithCoder:(NSCoder *)aDecoder;
- (void) dealloc;

- (void) awakeFromNib;
- (BOOL) isOpaque;
- (void) lockFocus;
- (void) drawRect:(CGRect)dirtyRect;
- (void) surfaceNeedsUpdate:(NSNotification *)notification;

@end
