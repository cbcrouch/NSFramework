//
//  NFCommonTypes.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#ifndef NSFramework_NFCommonTypes_h
#define NSFramework_NFCommonTypes_h


//
// TODO: #define OFFSET_OF to offsetof macro ?? (using all caps and underscore will help it standout as a macro)
//
#define ARRAY_COUNT(t, d) (sizeof(((t*)0x0)->d) / sizeof(((t*)0x0)->d[0]))


//
// TODO: should really stop being so lazy and split out the interleaved vertices (use 2 VB/IB pairs,
//       first just position [for depth only pass], second position and other interleaved data)
//

//
// TODO: need to get a better handle on common data types and make sure they align
//       with OpenGL data types
//

typedef struct NFVertex_t {
    // NOTE: w component of norm should be 0.0, and 1.0 for position (according to GLSL documentation
    //       for vectors w = 0 and for points w = 1)

    //
    // TODO: use a vec3 for both position and normal
    //
    float pos[4];
    float norm[4];
    float texCoord[3];
} NFVertex_t;


typedef struct NFDebugVertex_t {
    float pos[3];
    float norm[3];
    float color[4];
} NFDebugVertex_t;


typedef struct NFScreenSpaceVertex_t {
    float pos[2];
    float texCoord[2];
} NFScreenSpaceVertex_t;


typedef NS_ENUM(NSUInteger, NF_VERTEX_FORMAT) {
    kVertexFormatDefault,
    kVertexFormatDebug,
    kVertexFormatScreenSpace
};


typedef struct NFFace_t {
    unsigned short indices[3];

    //
    // TODO: in order to perform @encode on a struct it appears that all its members must be
    //       primitive data types, verify that this is correct and not a bug
    //
    //GLKVector4 normal;
    float normal[4];

    float area;
} NFFace_t;



#endif
