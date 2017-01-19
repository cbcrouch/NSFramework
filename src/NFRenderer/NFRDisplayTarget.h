//
//  NFRDisplayTarget.h
//  NSFramework
//
//  Copyright © 2017 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFRRenderTarget.h"

@interface NFRDisplayTarget : NSObject

@property (nonatomic, assign) GLsizei width;
@property (nonatomic, assign) GLsizei height;

//
// TODO: allow for chaining display targets together by definimg a transfer protol
//       that both render targets and display targets adhere to
//
@property (nonatomic, strong) NFRRenderTarget* transferSource;

- (void) processTransferOfAttachment:(NFR_ATTACHMENT_TYPE)attachmentType;

@end
