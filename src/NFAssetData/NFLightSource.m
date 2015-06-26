//
//  NFLightSource.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFLightSource.h"

#import "NFUtils.h"

@interface NFLightSource()

// derived values are readonly and are calculated when the values
// they are derived from are set
@property (nonatomic, retain) NSArray *halfVector;
@property (nonatomic, assign) float spotCosCutoff;

@end

@implementation NFLightSource

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        // set OpenGL default values
        _ambient = GLKVector3Make(0.0f, 0.0f, 0.0f);
        _position = GLKVector3Make(0.0f, 0.0f, 1.0f);
        _diffuse = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _specular = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _spotDirection = GLKVector3Make(0.0f, 0.0f, -1.0f);
        _spotExponent = 0.0f;
        _spotCutoff = M_PI;
        _constantAttenuation = 1.0f;
        _linearAttenuation = 0.0f;
        _quadraticAttenuation = 0.0f;
    }

    return self;
}

- (void) dealloc {
    [super dealloc];
}


- (void) setSpotCutoff:(float)spotCutoff {
    _spotCutoff = spotCutoff;
    [self setSpotCosCutoff:cosf(spotCutoff)];
}

//
// TODO: half vector is half way between surface normal and the light source vecotr
//       (or is it the vector from the surface towards the light ?? need to decide how it will be handled here)
//
/*
- (void) calcHalfVectorFromViewDir:(NSArray *)viewDir {
    //vec4 H = normalize( viewDir - lightDir );

    // need to determine the correct derived calculation that the OpenGL fixed
    // function pipeline is using

    // viewer (V) and the beam from a light-source (L)
    // H = (L + V) / (|L + V|)

    //vec4 H = normalize( lightDir + viewDir );
}
*/
@end


@implementation NFLightGroup

@end
