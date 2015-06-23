//
//  NFLightSource.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

//
// TODO: make sure struct definition will encompass a point light, spotlight, and directional light
//       and setup to operate similar to legacy OpenGL lights until working out a better model/design
//




@interface NFLightSource : NSObject

@property (nonatomic, assign) GLKVector3 ambient;   // Aclarri (Acli) also Acs ??
@property (nonatomic, assign) GLKVector3 diffuse;   // Dcli
@property (nonatomic, assign) GLKVector3 specular;  // Scli
@property (nonatomic, assign) GLKVector3 position;  // Ppli

// NOTE: the halfway vector (Hi) that is stored in the gl_LightSourceParameters is not a member of this
//       class since it is dependent on the geometry surface normal it will be calculated in the
//       shader where needed (this prevents coupling between the light definition and surface model)

@property (nonatomic, assign) GLKVector3 spotDirection;  // Sdli

@property (nonatomic, assign) float spotExponent;      // Srli
@property (nonatomic, assign) float spotCutoff;        // Crli (range: [0.0, 90.0], 180.0)

@property (nonatomic, readonly, assign) float spotCosCutoff;     // derived: cos(Crli) (range: [1.0, 0.0], -1.0)

@property (nonatomic, assign) float constantAttenuation;  // K0
@property (nonatomic, assign) float linearAttenuation;    // K1
@property (nonatomic, assign) float quadraticAttenuation; // K2

- (instancetype) init;
- (void) dealloc;

@end



@interface NFLightGroup : NSObject

//@property (nonatomic, retain) NSMutableArray *lights;

//@property (nonatomic, retain) NSMutableArray *lightModelProducts;

//@property (nonatomic, retain) NSMutableArray *lightProducts;

//- (void) calculateProductsFromSurfaces:(NSMutableArray *) surfaces;

@end


