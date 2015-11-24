//
//  NFRRenderRequest.m
//  NSFramework
//
//  Copyright © 2015 Casey Crouch. All rights reserved.
//

#import "NFRRenderRequest.h"

#import "NFRDefaultProgram.h"
#import "NFRDebugProgram.h"
#import "NFRDisplayProgram.h"

@implementation NFRRenderRequest

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
    //       multiple program objects (this should work in theory but hasn't been tested)
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
    // TODO: loadLight should only be called if the light has been changed (add a dirty flag ??)
    //
    for (id<NFLightSource> light in self.lightsArray) {
        if ([self.program respondsToSelector:@selector(loadLight:)]) {
            [self.program performSelector:@selector(loadLight:) withObject:light];
        }
    }

    //
    // TODO: rather than having a geometry array have an array of draw blocks to execute ??
    //       (program handle would be bound and unbound prior to processing the blocks array)
    //

    /*
     glUseProgram(self.program.hProgram);
     for (void ^(void)block in self.blocks) {
     block();
     }
     glUseProgram(0);
     */

    glUseProgram(self.program.hProgram);
    for (NFRGeometry* geo in self.geometryArray) {
        [self.program drawGeometry:geo];
    }
    glUseProgram(0);
}

- (void) dealloc {
    [_geometryArray release];
    [_lightsArray release];
    [super dealloc];
}

@end
