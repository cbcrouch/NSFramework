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

- (void) addGeometry:(NFRGeometry*)geometry {
    if (_geometryArray == nil) {
        _geometryArray = [[[NSMutableArray alloc] init] retain];
    }
    [_geometryArray addObject:geometry];
}

- (void) process {
    for (NFRGeometry* geo in self.geometryArray) {
        [self.program drawGeometry:geo];
    }
}

- (void) dealloc {
    [_geometryArray release];
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

