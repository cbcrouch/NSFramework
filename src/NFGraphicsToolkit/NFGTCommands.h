//
//  NFGTCommands.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "NFGTDataTypes.h"

@protocol GTDevice;



@protocol GTCommandBuffer <NSObject>

//
// TODO: implement
//

@end



@protocol GTCommandQueue <NSObject>

@property (nonatomic, copy) NSString* label;
@property (nonatomic, readonly) id<GTDevice> device;

- (id<GTCommandBuffer>) commandBuffer;
- (id<GTCommandBuffer>) commandBufferWithUnretainedReferences;

@end





@interface NFGTCommands : NSObject

@end
