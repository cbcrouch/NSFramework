//
//  NFRDisplayTarget.h
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFRRenderTarget.h"

@interface NFRDisplayTarget : NSObject

@property (nonatomic, assign) GLsizei width;
@property (nonatomic, assign) GLsizei height;

@property (nonatomic, strong) NFRRenderTarget* transferSource;

- (void) processTransfer;

@end
