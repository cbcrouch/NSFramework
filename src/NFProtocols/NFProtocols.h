//
//  NFProtocols.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NFObserverProtocol <NSObject>

- (void) notify;

@end


@protocol NFDataSourceProtocol <NSObject>

- (void) addObserver:(id)obj;

@end
