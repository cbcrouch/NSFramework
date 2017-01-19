//
//  NFRRenderRequest.m
//  NSFramework
//
//  Copyright © 2017 Casey Crouch. All rights reserved.
//

#import "NFRRenderRequest.h"

#import "NFRDefaultProgram.h"
#import "NFRDebugProgram.h"
#import "NFRDisplayProgram.h"


@implementation NFRCommandBufferDebug

- (NSMutableArray*) geometryArray {
    if (_geometryArray == nil) {
        _geometryArray = [[NSMutableArray alloc] init];
    }
    return _geometryArray;
}

- (void) addGeometry:(NFRGeometry*)geometry {
    [self.geometryArray addObject:geometry];
}

- (void) drawWithProgram:(id<NFRProgram>)program {
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


@implementation NFRCommandBufferDefault

- (NSMutableArray*) geometryArray {
    if (_geometryArray == nil) {
        _geometryArray = [[NSMutableArray alloc] init];
    }
    return _geometryArray;
}

- (NSMutableArray*) lightsArray {
    if (_lightsArray == nil) {
        _lightsArray = [[NSMutableArray alloc] init];
    }
    return _lightsArray;
}

- (void) addGeometry:(NFRGeometry*)geometry {
    [self.geometryArray addObject:geometry];

    //
    // TODO: need to configure the programs vertex shader inputs just once per program/vao
    //

    // right now each geometry object has its own VAO

    // the following two functions will enable the shader's vertex attributes and then set attribute pointers

    //[self.program configureVertexInput:geometry.vertexBuffer.bufferAttributes];
    //[self.program configureVertexBufferLayout:geometry.vertexBuffer withAttributes:geometry.vertexBuffer.bufferAttributes];
}

- (void) addLight:(id<NFLightSource>)light {
    [self.lightsArray addObject:light];
}

//
// TODO: this method should return a block that accepts a program argument and has captured
//       the light and geometry arrays from the command buffer object (alternative implementation)
//
- (void) drawWithProgram:(id<NFRProgram>)program {
    //
    // TODO: loadLight should only be called if the light has been changed (add a dirty flag ??)
    //
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

//
//
//

@implementation NFRRenderRequest

- (NSMutableArray*) commandBufferArray {
    if (_commandBufferArray == nil) {
        _commandBufferArray = [[NSMutableArray alloc] init];
    }
    return _commandBufferArray;
}

- (void) addCommandBuffer:(id<NFRCommandBufferProtocol>)commandBuffer {
    [self.commandBufferArray addObject:commandBuffer];
}

- (void) process {

    //
    // TODO: implement setPipelineState to set/configure global OpenGL state
    //
    //[self setPipelineState];

    for (id<NFRCommandBufferProtocol> commandBuffer in self.commandBufferArray) {
        [commandBuffer drawWithProgram:self.program];
    }
}


@end
