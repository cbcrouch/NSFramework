//
//  NFLightSource.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFLightSource.h"

//
// NFPointLight
//

@interface NFPointLight()
@property (nonatomic, readwrite, assign) GLKMatrix4 modelMatrix;
@property (nonatomic, readwrite, retain) NFAssetData* geometry;
@end


@implementation NFPointLight

@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize position = _position;

@synthesize modelMatrix = _modelMatrix;
@synthesize geometry = _geometry;

//
// TODO: override the position setter to update the modelMatrix when the position changes
//

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        //
        // TODO: load some sensible default values
        //

        // point light geometry will be a sphere
    }
    return self;
}

@end

//
// NFDirectionalLight
//

@interface NFDirectionalLight()
@property (nonatomic, readwrite, assign) GLKMatrix4 modelMatrix;
@property (nonatomic, readwrite, retain) NFAssetData* geometry;
@end

@implementation NFDirectionalLight

@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize position = _position;

@synthesize modelMatrix = _modelMatrix;
@synthesize geometry = _geometry;

//
// TODO: override the position setter to update the modelMatrix when the position changes
//

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

@end

//
// NFSpotLight
//

@interface NFSpotLight()
@property (nonatomic, readwrite, assign) GLKMatrix4 modelMatrix;
@property (nonatomic, readwrite, retain) NFAssetData* geometry;
@end

@implementation NFSpotLight

@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize position = _position;

@synthesize modelMatrix = _modelMatrix;
@synthesize geometry = _geometry;

//
// TODO: override the position setter to update the modelMatrix when the position changes
//

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

@end
