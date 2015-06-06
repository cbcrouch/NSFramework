//
//  NFGraphicsToolkit.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFGraphicsToolkit.h"


@interface GTFunctionImplGL : NSObject <GTFunction>

// function impl corresponds to one shader stage e.g. vertex shader

//@property (nonatomic, assign) GLuint handle;

//
// TODO: optionally store shader source
//

- (instancetype) initWithName:(NSString*)name;

@end


@implementation GTFunctionImplGL

@synthesize name = _name;
@synthesize functionType = _functionType;
@synthesize device = _device;
@synthesize vertexAttributes = _vertexAttributes;

- (instancetype) initWithName:(NSString *)name {

    //
    // TODO: implement
    //

    return nil;
}

@end





@interface GTLibraryImplGL : NSObject <GTLibrary>

@end

@implementation GTLibraryImplGL

@synthesize label = _label;
@synthesize device = _device;
@synthesize functionNames = _functionNames;

//
// TODO: implement
//

- (id<GTFunction>) newFunctionWithName:(NSString *)functionName {
    return nil;
}

@end
