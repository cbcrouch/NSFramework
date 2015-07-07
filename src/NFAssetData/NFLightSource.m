//
//  NFLightSource.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFLightSource.h"
#import "NFAssetLoader.h"

//
// NFPointLight
//

@interface NFPointLight()
@property (nonatomic, readwrite, retain) NFAssetData* geometry;
@end


@implementation NFPointLight

@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize position = _position;

@synthesize geometry = _geometry;

- (void) setPosition:(GLKVector3)position {
    _position = position;
    _geometry.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, position.x, position.y, position.z);
    _geometry.modelMatrix = GLKMatrix4Scale(_geometry.modelMatrix, 0.065f, 0.065f, 0.065f);

    //
    // TODO: currently need to apply a single step to the sphere in order to have its tranforms
    //       applied, need to find a better/cleaner way to initialize the transforms
    //
    [_geometry stepTransforms:0.0f];
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        //
        // TODO: load some sensible default values
        //

        // point light geometry will be a sphere
        _geometry = [NFAssetLoader allocAssetDataOfType:kSolidUVSphere withArgs:nil];
        [_geometry generateRenderables];

        _geometry.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 2.0f, 1.0f, 0.0f);
        _geometry.modelMatrix = GLKMatrix4Scale(_geometry.modelMatrix, 0.065f, 0.065f, 0.065f);

        //
        // TODO: currently need to apply a single step to the sphere in order to have its tranforms
        //       applied, need to find a better/cleaner way to initialize the transforms
        //
        [_geometry stepTransforms:0.0f];

    }
    return self;
}

- (void) dealloc {
    [_geometry release];
    [super dealloc];
}

@end

//
// NFDirectionalLight
//

@interface NFDirectionalLight()
@property (nonatomic, readwrite, retain) NFAssetData* geometry;
@end

@implementation NFDirectionalLight

@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize position = _position;
@synthesize geometry = _geometry;

- (void) setPosition:(GLKVector3)position {
    _position = position;
    _geometry.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, position.x, position.y, position.z);
    _geometry.modelMatrix = GLKMatrix4Scale(_geometry.modelMatrix, 0.065f, 0.065f, 0.065f);
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        //
        // TODO: load some sensible default values
        //

        // directional light geometry will be a cylinder
    }
    return self;
}

- (void) dealloc {
    [_geometry release];
    [super dealloc];
}

@end

//
// NFSpotLight
//

@interface NFSpotLight()
@property (nonatomic, readwrite, retain) NFAssetData* geometry;
@end

@implementation NFSpotLight

@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize position = _position;
@synthesize geometry = _geometry;

- (void) setPosition:(GLKVector3)position {
    _position = position;
    _geometry.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, position.x, position.y, position.z);
    _geometry.modelMatrix = GLKMatrix4Scale(_geometry.modelMatrix, 0.065f, 0.065f, 0.065f);
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        //
        // TODO: load some sensible default values
        //

        // spot light geometry will be a cone
    }
    return self;
}

- (void) dealloc {
    [_geometry release];
    [super dealloc];
}

@end
