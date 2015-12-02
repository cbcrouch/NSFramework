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


@implementation NFRCommandBufferDebug

//

@end



@implementation NFRCommandBufferDefault

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
    // TODO: need to configure the programs vertex shader inputs just once per program/vao
    //

    // right now each geometry object has its own vao

    // the following two functions will enable the shader's vertex attributes and then set attribute pointers

    //[self.program configureVertexInput:geometry.vertexBuffer.bufferAttributes];
    //[self.program configureVertexBufferLayout:geometry.vertexBuffer withAttributes:geometry.vertexBuffer.bufferAttributes];
}

- (void) addLight:(id<NFLightSource>)light {
    [self.lightsArray addObject:light];
}

//
// TODO: this method should return a block that accepts a program argument and has captured
//       the light and geometry arrays from the command buffer object
//
- (void) drawWithProgram:(id<NFRProgram>)program {

    for (id<NFLightSource> light in self.lightsArray) {
        if ([program respondsToSelector:@selector(loadLight:)]) {
            [program performSelector:@selector(loadLight:) withObject:light];
        }
    }

    //
    // TODO: this is really inefficient and should be fixed
    //
    for (NFRGeometry* geo in self.geometryArray) {
        [program configureVertexInput:geo.vertexBuffer.bufferAttributes];
        [program configureVertexBufferLayout:geo.vertexBuffer withAttributes:geo.vertexBuffer.bufferAttributes];
    }


    glUseProgram(program.hProgram);
    for (NFRGeometry* geo in self.geometryArray) {
        [program drawGeometry:geo];
    }
    glUseProgram(0);

}

@end



@implementation NFRCommandBufferDisplay

//

@end




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
    // TODO: integrate command buffers with render request
    //

    // render request will take general render state like setting clear calls or depth buffer state etc.

    // command buffer and program object will each have a descriptor object (will contain vertex format, uniforms, etc.)
    // and when in debug mode a render request will verify that they both match


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
