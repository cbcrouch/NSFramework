//
//  NFProtocols.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>


// could use NSNotificationCenter to implement observer pattern
// https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/

// or could use key-value observing
// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html


@protocol NFObserverProtocol <NSObject>

- (void) notifyOfStateChange;

@end


@protocol NFDataSourceProtocol <NSObject>

- (void) addObserver:(id)obj;

@end
