//
//  NFLightSource.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFLightSource.h"

#import "NFAssetData.h"
#import "NFAssetLoader.h"

//
// NFPointLight
//

@interface NFPointLight()
@property (nonatomic, retain) NFAssetData* assetData;
@end


@implementation NFPointLight

@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize position = _position;

@synthesize geometry = _geometry;

- (void) setPosition:(GLKVector3)position {
    _position = position;
    _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, position.x, position.y, position.z);
    _assetData.modelMatrix = GLKMatrix4Scale(_assetData.modelMatrix, 0.065f, 0.065f, 0.065f);

    //
    // TODO: currently need to apply the updated model matrix to the subsets manually
    //       (need to find a better/cleaner way to stack the transforms)
    //
    for (NFAssetSubset *subset in self.assetData.subsetArray) {
        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.assetData.modelMatrix, subset.subsetModelMat);
        [self.assetData.geometry setModelMatrix:renderModelMat];
    }
}

- (NFRGeometry*) geometry {
    return _assetData.geometry;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        //
        // TODO: load some sensible default values
        //

        // point light geometry will be a sphere
        _assetData = [NFAssetLoader allocAssetDataOfType:kSolidUVSphere withArgs:(id)kVertexFormatDebug, nil];
        [_assetData generateRenderables];

        _position = GLKVector3Make(2.0f, 1.0f, 0.0f);

        _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 2.0f, 1.0f, 0.0f);
        _assetData.modelMatrix = GLKMatrix4Scale(_assetData.modelMatrix, 0.065f, 0.065f, 0.065f);

        //
        // TODO: currently need to apply a single step to the sphere in order to have its tranforms
        //       applied, need to find a better/cleaner way to initialize the transforms
        //
        [_assetData stepTransforms:0.0f];

        _ambient = GLKVector3Make(0.2f, 0.2f, 0.2f);
        _diffuse = GLKVector3Make(0.5f, 0.5f, 0.5f);

        //_ambient = GLKVector3Make(1.0f, 1.0f, 1.0f);
        //_diffuse = GLKVector3Make(1.0f, 1.0f, 1.0f);

        _specular = GLKVector3Make(1.0f, 1.0f, 1.0f);

        _constantAttenuation = 1.0f;

        // good for a distance of 13
        //_linearAttenuation = 0.35f;
        //_quadraticAttenuation = 0.44f;

        // good for a distance of 7
        _linearAttenuation = 0.7f;
        _quadraticAttenuation = 1.8f;
    }
    return self;
}

- (void) dealloc {
    [_assetData release];
    [super dealloc];
}

- (void) stepTransforms:(float)secsElapsed {
    typedef GLKMatrix4 (^transformBlock_f)(GLKMatrix4, float);
    transformBlock_f transformBlock = ^(GLKMatrix4 modelMatrix, float secsElapsed) {
        float angle = secsElapsed * M_PI_4 * -1.25;
        return GLKMatrix4MakeRotation(angle, 0.0f, 1.0f, 0.0f);

    };

    GLKMatrix4 tempMat = transformBlock(GLKMatrix4Identity, secsElapsed);

    // NOTE: have to perform this step since when multiplying by vec3 GLK will use w = 0.0f
    GLKVector4 tempVec = GLKMatrix4MultiplyVector4(tempMat, GLKVector4MakeWithVector3(self.position, 1.0f));
    self.position = GLKVector3Make(tempVec.x, tempVec.y, tempVec.z);
}

@end

//
// NFDirectionalLight
//

@interface NFDirectionalLight()
@property (nonatomic, retain) NFAssetData* assetData;
@end

@implementation NFDirectionalLight

@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize position = _position;
@synthesize geometry = _geometry;

- (void) setPosition:(GLKVector3)position {
    _position = position;

    //
    // TODO: also need to take into account the direction the light is facing
    //
    _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, position.x, position.y, position.z);

    [_assetData stepTransforms:0.0f];

    for (NFAssetSubset *subset in self.assetData.subsetArray) {
        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.assetData.modelMatrix, subset.subsetModelMat);
        [self.assetData.geometry setModelMatrix:renderModelMat];
    }
}

- (NFRGeometry*) geometry {
    return _assetData.geometry;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {

        // directional light geometry will be a cylinder


        // point light geometry will be a sphere
        _assetData = [NFAssetLoader allocAssetDataOfType:kSolidCylinder withArgs:(id)kVertexFormatDebug, nil];
        [_assetData generateRenderables];

        _position = GLKVector3Make(-2.0f, 2.0f, 1.0f);



        //
        // TODO: rotate so the cylinder it is facing the origin prior to translating the asset data
        //

        // this should point the directional light towards to the origin
        _direction = GLKVector3MultiplyScalar(_position, -1.0f);

        // use direction to determine rotation
        //float radians = M_PI_2;
        //_assetData.modelMatrix = GLKMatrix4Rotate(_assetData.modelMatrix, radians, 0.0f, 0.0f, 1.0f);

        //GLKMatrix4 tempMat = GLKMatrix4MakeLookAt(-2.0f, 2.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
        //_assetData.modelMatrix = GLKMatrix4Multiply(_assetData.modelMatrix, tempMat);



        _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, _position.x, _position.y, _position.z);
        _assetData.modelMatrix = GLKMatrix4Scale(_assetData.modelMatrix, 0.065f, 0.065f, 0.065f);

        //
        // TODO: currently need to apply a single step to the sphere in order to have its tranforms
        //       applied, need to find a better/cleaner way to initialize the transforms
        //
        [_assetData stepTransforms:0.0f];

        _ambient = GLKVector3Make(0.2f, 0.2f, 0.2f);
        _diffuse = GLKVector3Make(0.5f, 0.5f, 0.5f);
        _specular = GLKVector3Make(1.0f, 1.0f, 1.0f);
    }
    return self;
}

- (void) dealloc {
    [_assetData release];
    [super dealloc];
}

@end

//
// NFSpotLight
//

@interface NFSpotLight()
@property (nonatomic, retain) NFAssetData* assetData;
@end

@implementation NFSpotLight

@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize position = _position;
@synthesize geometry = _geometry;

- (void) setPosition:(GLKVector3)position {
    _position = position;

    //
    // TODO: also need to take into account the direction the light is facing
    //
    _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, position.x, position.y, position.z);

    [_assetData stepTransforms:0.0f];

    for (NFAssetSubset *subset in self.assetData.subsetArray) {
        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.assetData.modelMatrix, subset.subsetModelMat);
        [self.assetData.geometry setModelMatrix:renderModelMat];
    }
}

- (NFRGeometry*) geometry {
    return _assetData.geometry;
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
    [_assetData release];
    [super dealloc];
}

@end
