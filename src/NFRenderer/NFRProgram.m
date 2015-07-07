//
//  NFRProgram.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRProgram.h"

#import "NFCommonTypes.h"
#import "NFRUtils.h"

#import "NFSurfaceModel.h"
#import "NFRDataMap.h"

#import "NFRDefaultProgram.h"
#import "NFRDebugProgram.h"


@implementation NFRRenderRequest

@synthesize geometryArray = _geometryArray;

- (NSMutableArray*) geometryArray {
    if (_geometryArray == nil) {
        _geometryArray = [[[NSMutableArray alloc] init] retain];
    }
    return _geometryArray;
}

- (NSMutableArray*) lightsArray {
    if (_lightsArray == nil) {
        _lightsArray = [[[NSMutableArray alloc] init] retain];
    }
    return _lightsArray;
}

- (void) addGeometry:(NFRGeometry*)geometry {
    [self.geometryArray addObject:geometry];

    //
    // TODO: geometry objects should be able to be added to multiple render requests and drawn with
    //       multiple program objects
    //

    //
    // NOTE: geometry will now be bound to the shader program here
    //
    [self.program configureVertexInput:geometry.vertexBuffer.bufferAttributes];
    [self.program configureVertexBufferLayout:geometry.vertexBuffer withAttributes:geometry.vertexBuffer.bufferAttributes];
}

- (void) addLight:(id<NFLightSource>)light {
    [self.lightsArray addObject:light];
}

- (void) process {

    //
    // TODO: add support for light sources in the render request
    //
    //for (id<NFLightSource> light in self.lightsArray) {
    //}

    for (NFRGeometry* geo in self.geometryArray) {
        [self.program drawGeometry:geo];
    }
}

- (void) dealloc {
    [_geometryArray release];
    [_lightsArray release];
    [super dealloc];
}

@end


//
//
//

@implementation NFRProgram

+ (id<NFRProgram>) createProgramObject:(NSString *)programName {

    if ([programName isEqualToString:@"DefaultModel"]) {
        NFRDefaultProgram* programObj = [[[NFRDefaultProgram alloc] init] autorelease];
        [programObj setHProgram:[NFRUtils createProgram:programName]];
        [programObj loadProgramInputPoints];
        return programObj;
    }
    else if ([programName isEqualToString:@"Debug"]) {
        NFRDebugProgram* programObj = [[[NFRDebugProgram alloc] init] autorelease];
        [programObj setHProgram:[NFRUtils createProgram:programName]];
        [programObj loadProgramInputPoints];
        return programObj;
    }
    else {
        NSLog(@"WARNING: NFRUtils createProgramObject attempted to load an unknown program, returning nil");
    }
    
    return nil;
}

@end

