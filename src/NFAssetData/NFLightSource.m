//
//  NFLightSource.m
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import "NFUtils.h"

#import "NFLightSource.h"

#import "NFAssetData.h"
#import "NFAssetLoader.h"

//
// NFPointLight
//

@interface NFPointLight()
@property (nonatomic, strong) NFAssetData* assetData;
@end


@implementation NFPointLight

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
        (self.assetData.geometry).modelMatrix = renderModelMat;
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
        _assetData = [NFAssetLoader allocAssetDataOfType:kSolidUVSphere withArgs:@(kVertexFormatDebug), nil];
        [_assetData generateRenderables];

        _position = GLKVector3Make(2.0f, 1.0f, 0.0f);

        _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 2.0f, 1.0f, 0.0f);
        _assetData.modelMatrix = GLKMatrix4Scale(_assetData.modelMatrix, 0.065f, 0.065f, 0.065f);

        //
        // TODO: currently need to apply a single step to the sphere in order to have its tranforms
        //       applied, need to find a better/cleaner way to initialize the transforms
        //
        [_assetData stepTransforms:0.0f];

        //_ambient = GLKVector3Make(0.2f, 0.2f, 0.2f);
        //_diffuse = GLKVector3Make(0.5f, 0.5f, 0.5f);

        _ambient = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _diffuse = GLKVector3Make(1.0f, 1.0f, 1.0f);
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
@property (nonatomic, strong) NFAssetData* assetData;
@end

@implementation NFDirectionalLight

- (void) setPosition:(GLKVector3)position {
    _position = position;

    //
    // TODO: also need to take into account the direction the light is facing
    //
    _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, position.x, position.y, position.z);

    [_assetData stepTransforms:0.0f];

    for (NFAssetSubset *subset in self.assetData.subsetArray) {
        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.assetData.modelMatrix, subset.subsetModelMat);
        (self.assetData.geometry).modelMatrix = renderModelMat;
    }
}

- (NFRGeometry*) geometry {
    return _assetData.geometry;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {

        // directional light geometry will be a cylinder

        //
        // TODO: will ideally want to create a cylinder with just one, roughly, quarter of it with a bright
        //       white texture and the rest of the cylinder a flat gray to visualize which direction the
        //       the light vector is going
        //
        _assetData = [NFAssetLoader allocAssetDataOfType:kSolidCylinder withArgs:@(kVertexFormatDebug), nil];
        [_assetData generateRenderables];

        _position = GLKVector3Make(-2.0f, 2.0f, 1.0f);

        _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, _position.x, _position.y, _position.z);
        _assetData.modelMatrix = GLKMatrix4Scale(_assetData.modelMatrix, 0.065f, 0.065f, 0.065f);


        GLKVector3 orig = GLKVector3Make(0.0f, -1.0f, 0.0f);
        orig = GLKVector3Normalize(orig);

        // NOTE: this should always make the geometry face the origin
        GLKVector3 dest = GLKVector3MultiplyScalar(_position, -1.0f);
        dest = GLKVector3Normalize(dest);

        GLKQuaternion rotationQuat = [NFUtils rotateVector:orig toDirection:dest];

        // NOTE: this will make the bottom face of the cylinder point towards the origin
        GLKMatrix4 rotationMatrix = GLKMatrix4MakeWithQuaternion(rotationQuat);
        _assetData.modelMatrix = GLKMatrix4Multiply(_assetData.modelMatrix, rotationMatrix);


        //
        // TODO: currently need to apply a single step to the sphere in order to have its tranforms
        //       applied, need to find a better/cleaner way to initialize the transforms
        //
        [_assetData stepTransforms:0.0f];

        _direction = dest;

        //
        // TODO: directional light defaults should be very faint
        //
#if 0
        _ambient = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _diffuse = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _specular = GLKVector3Make(1.0f, 1.0f, 1.0f);
#else
        _ambient = GLKVector3Make(0.02f, 0.02f, 0.02f);
        _diffuse = GLKVector3Make(0.05f, 0.05f, 0.05f);
        _specular = GLKVector3Make(0.75f, 0.75f, 0.75f);
#endif
    }
    return self;
}


@end

//
// NFSpotLight
//

@interface NFSpotLight()
@property (nonatomic, strong) NFAssetData* assetData;
@end

@implementation NFSpotLight

- (void) setPosition:(GLKVector3)position {
    _position = position;

    //
    // TODO: also need to take into account the direction the light is facing
    //
    _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, position.x, position.y, position.z);

    [_assetData stepTransforms:0.0f];

    for (NFAssetSubset *subset in self.assetData.subsetArray) {
        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.assetData.modelMatrix, subset.subsetModelMat);
        (self.assetData.geometry).modelMatrix = renderModelMat;
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

        //
        // TODO: will ideally want to create a cone with just one, roughly, quarter of it with a bright
        //       white texture and the rest of the cone a flat gray to visualize which direction the
        //       the light vector is going (white would be bottom of the cone)
        //


        //
        // TODO: pass in values for height and slices for the cone
        //
        _assetData = [NFAssetLoader allocAssetDataOfType:kSolidCone withArgs:@(kVertexFormatDebug), nil];
        [_assetData generateRenderables];

        _position = GLKVector3Make(-2.0f, 1.0f, 2.0f);

        _assetData.modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, _position.x, _position.y, _position.z);
        _assetData.modelMatrix = GLKMatrix4Scale(_assetData.modelMatrix, 0.085f, 0.085f, 0.085f);

        GLKVector3 orig = GLKVector3Make(0.0f, -1.0f, 0.0f);
        orig = GLKVector3Normalize(orig);

        // NOTE: this should always make the geometry face the origin
        GLKVector3 dest = GLKVector3MultiplyScalar(_position, -1.0f);
        dest = GLKVector3Normalize(dest);

        GLKQuaternion rotationQuat = [NFUtils rotateVector:orig toDirection:dest];

        // NOTE: this will make the bottom face of the cylinder point towards the origin
        GLKMatrix4 rotationMatrix = GLKMatrix4MakeWithQuaternion(rotationQuat);
        _assetData.modelMatrix = GLKMatrix4Multiply(_assetData.modelMatrix, rotationMatrix);

        _direction = dest;


        //
        // TODO: currently need to apply a single step to the sphere in order to have its tranforms
        //       applied, need to find a better/cleaner way to initialize the transforms
        //
        [_assetData stepTransforms:0.0f];


        _ambient = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _diffuse = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _specular = GLKVector3Make(1.0f, 1.0f, 1.0f);


        //
        // TODO: document some good angles to use for the inner and outer cutoff as well as their
        //       relationship to how the spot light will appear
        //
        _innerCutOff = cosf(12.5f * M_PI/180.0f);
        _outerCutOff = cosf(17.5f * M_PI/180.0f);


        // NOTE: use same attenuation values as with the point light
        _constantAttenuation = 1.0f;

        // good for a distance of 13
        _linearAttenuation = 0.35f;
        _quadraticAttenuation = 0.44f;

        // good for a distance of 7
        //_linearAttenuation = 0.7f;
        //_quadraticAttenuation = 1.8f;
    }
    return self;
}


@end
