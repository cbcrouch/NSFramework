//
//  NFWavefrontObj.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFAssetData.h"

//#import "NFSurfaceModel.h"

//
// TODO: should remove use of these enums and the PhongMaterial_t struct and use the surface
//       model object
//
typedef NS_ENUM(NSUInteger, ILLUMINATION_MODEL) {
    kColorOnAmbientOff,
    kColorOnAmbientOn,
    kHighlightOn,
    kReflectionOn,
    kTransparencyOn,
    kShadowInvisibleSurfaces
};

// NOTE: when transparency is on then either refraction or glass must be on
typedef NS_ENUM(NSUInteger, TRANSPARENCY_MODEL) {
    kRefractionOn,
    kGlassOn
};

// NOTE: reflection can be on with neither ray trace or fresnel enable
//       though ray trace must be on to support fresenl
typedef NS_ENUM(NSUInteger, REFLECTION_MODEL) {
    kRayTracOn,
    kFresnelOn
};


//
// TODO: try using ALIGN(p) or ALIGNBYTES and benchmark byte aligned versus not byte aligned structs
//
typedef struct xyz3f_t {
    float x;
    float y;
    float z;
} Vertex3f_t, Vector3f_t;

typedef struct PhongMaterial_t {
    NSString *name;

    float Ns; // specular coefficient
    float Ni; // optical density (also known as index of refraction)

    // dissolve factor e.g. d -halo 0.0 or d 0.0
    float d;
    BOOL dHalo;

    float Tr; // transparency

    float Tf[3]; // transmission filter

    NSInteger illum; // illumination model

    float Ka[3]; // ambient color
    float Kd[3]; // diffuse color
    float Ks[3]; // specular color

    float Ke[3]; // emissive color


    //
    // TODO: record as an NSImage and then parse to an NFDataMap in the category that way
    //       can remove the dependency on renderer internals from the Wavefront obj parsing
    //
    NFDataMap *map_Ka; // ambient color texture map (will be same as diffuse most of the time)
    NFDataMap *map_Kd; // diffuse color texture map
    NFDataMap *map_Ks; // specular color texture map
    NFDataMap *map_Ns; // specular highlight component

    //NFDataMap *map_Tr; // transparency map ??

    //NFDataMap *map_bump; // or broken out into: bump, disp, decalT
    
} PhongMaterial_t;


// container for Wavefront object
@interface WFObject : NSObject
@property (nonatomic, retain) NSString *objectName;
@property (nonatomic, retain) NSMutableArray *groups;

@property (nonatomic, retain) NSMutableArray *vertices;
@property (nonatomic, retain) NSMutableArray *textureCoords;
@property (nonatomic, retain) NSMutableArray *normals;
@end


// container for Wavefront object groups
@interface WFGroup : NSObject
@property (nonatomic, retain) NSString *groupName;
@property (nonatomic, retain) NSString *materialName;
@property (nonatomic, retain) NSMutableArray *faceStrArray;
@end


@interface NFWavefrontObj : NSObject

//
// TODO: will need an NSMutableArray property for storing multiple objects
//       (currently only support one "o" object per file)
//
//@property (nonatomic, retain) NSMutableArray *objectsArray;
@property (nonatomic, retain) WFObject *object;

@property (nonatomic, retain) NSMutableArray *materialsArray;


- (instancetype) init;
- (void) dealloc;

- (void) loadFileWithPath:(NSString *)filePath;
- (void) loadFile:(NSString *)fileName; // inBundle:(NSBundle)bundle

- (void) parseFile;

@end
