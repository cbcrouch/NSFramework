//
//  NFWavefrontObj.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFAssetData.h"
#import "NFSurfaceModel.h"


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


typedef NS_ENUM(NSUInteger, FaceGroupType) {
    kGroupIndexVertex = 0,
    kGroupIndexTex = 1,
    kGroupIndexNorm = 2
};


static NSInteger (^normalizeObjIndex)(NSInteger, NSUInteger) = ^ NSInteger (NSInteger index, NSUInteger numElements) {
    // return -1 if the index or the numElements are 0, -1 should be treated as "value not present"
    if (index == 0 || numElements == 0) {
        return -1;
    }
    return (index > 0) ? (index - 1) : (numElements + index);
};


// container for Wavefront object
@interface WFObject : NSObject
@property (nonatomic, retain) NSString *objectName;
@property (nonatomic, retain) NSMutableArray *groups;

@property (nonatomic, retain) NSMutableArray *vertices;
@property (nonatomic, retain) NSMutableArray *textureCoords;
@property (nonatomic, retain) NSMutableArray *normals;

- (void) calculateTextureCoordinates;
- (void) calculateNormals;

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

//
// TODO: load and write methods should return an error of some kind if they fail
//
- (void) loadFileWithPath:(NSString *)filePath;
- (void) loadFile:(NSString *)fileName; // inBundle:(NSBundle)bundle

//
// TODO: add ability to write Wavefront object files
//
//- (void) writeAsset:(NFAssetData *)assetData toFile:(NSString *)filePath;

- (void) parseFile;

@end
