//
//  NFRDisplayTarget.h
//  NSFramework
//
//  Copyright © 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFRRenderTarget.h"

@interface NFRDisplayTarget : NSObject

@property (nonatomic, assign) GLsizei width;
@property (nonatomic, assign) GLsizei height;

@property (nonatomic, retain) NFRRenderTarget* transferSource;


//
// TODO: display method needs a better name (process or transfer ?)
//
- (void) display;

@end
