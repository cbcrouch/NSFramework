//
//  NFLightSource.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// TODO: migrate NFLightSource to NFGraphicsToolkit
//


@interface NFLightSource : NSObject

//
// NOTE: class is based on gl_LightSourceParameters
//

@property (nonatomic, retain) NSArray *ambient;   // Aclarri (Acli) also Acs ??
@property (nonatomic, retain) NSArray *diffuse;   // Dcli
@property (nonatomic, retain) NSArray *specular;  // Scli
@property (nonatomic, retain) NSArray *position;  // Ppli

// NOTE: the halfway vector (Hi) that is stored in the gl_LightSourceParameters is not a member of this
//       class since it is dependent on the geometry surface normal it will be calculated in the
//       shader where needed (this prevents coupling between the light definition and surface model)

@property (nonatomic, retain) NSArray *spotDirection;  // Sdli
@property (nonatomic, assign) float spotExponent;      // Srli
@property (nonatomic, assign) float spotCutoff;        // Crli (range: [0.0, 90.0], 180.0)

@property (nonatomic, readonly, assign) float spotCosCutoff;     // derived: cos(Crli) (range: [1.0, 0.0], -1.0)

@property (nonatomic, assign) float constantAttenuation;  // K0
@property (nonatomic, assign) float linearAttenuation;    // K1
@property (nonatomic, assign) float quadraticAttenuation; // K2

- (instancetype) init;
- (void) dealloc;

@end

/*
struct gl_MaterialParameters
{
    vec4 emission;    // Ecm
    vec4 ambient;     // Acm
    vec4 diffuse;     // Dcm
    vec4 specular;    // Scm
    float shininess;  // Srm
};

uniform gl_MaterialParameters gl_FrontMaterial;
uniform gl_MaterialParameters gl_BackMaterial;
*/

//
// derived state from products of light and material
//
/*
struct gl_LightModelProducts
{
    vec4 sceneColor; // Derived. Ecm + Acm * Acs
};

uniform gl_LightModelProducts gl_FrontLightModelProduct;
uniform gl_LightModelProducts gl_BackLightModelProduct;


struct gl_LightProducts
{
    vec4 ambient;    // Acm * Acli
    vec4 diffuse;    // Dcm * Dcli
    vec4 specular;   // Scm * Scli
};

uniform gl_LightProducts gl_FrontLightProduct[gl_MaxLights];
uniform gl_LightProducts gl_BackLightProduct[gl_MaxLights];
*/


@interface NFLightGroup : NSObject

//@property (nonatomic, strong) NSMutableArray *lights;

//@property (nonatomic, strong) NSMutableArray *lightModelProducts;

//@property (nonatomic, strong) NSMutableArray *lightProducts;

//- (void) calculateProductsFromSurfaces:(NSMutableArray *) surfaces;

@end


