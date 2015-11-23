//
//  NFRDisplayProgram.m
//  NSFramework
//
//  Copyright © 2015 Casey Crouch. All rights reserved.
//

#import "NFRDisplayProgram.h"

@implementation NFRDisplayProgram


//
// TODO: init and load the program
//

- (void) loadProgramInputPoints {
    //
    // TODO: implement
    //
}


//
// TODO: these two methods should be marked optional in the program protocol
//
- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection {
    //
}

- (void) updateModelMatrix:(GLKMatrix4)modelMatrix {
    //
}



- (void) drawGeometry:(NFRGeometry *)geometry {
    //
}

- (void) configureVertexBufferLayout:(NFRBuffer *)vertexBuffer withAttributes:(NFRBufferAttributes *)bufferAttributes {
    //
}

- (void) configureVertexInput:(NFRBufferAttributes *)bufferAttributes {
    //
}

@end
