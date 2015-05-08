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
        float tempArray[] = {0.0f, 0.0f, 0.0f, 1.0f};

        [self setAmbient:convertCfloatArrayToNS(tempArray)];

        tempArray[0] = 0.0f;
        tempArray[1] = 0.0f;
        tempArray[2] = 1.0f;
        tempArray[3] = 0.0f;

        [self setPosition:convertCfloatArrayToNS(tempArray)];

        tempArray[0] = 1.0f;
        tempArray[1] = 1.0f;
        tempArray[2] = 1.0f;
        tempArray[3] = 1.0f;

        [self setDiffuse:convertCfloatArrayToNS(tempArray)];
        [self setSpecular:convertCfloatArrayToNS(tempArray)];

        tempArray[0] = 0.0f;
        tempArray[1] = 0.0f;
        tempArray[2] = -1.0f;

        [self setSpotDirection:convertCfloatArrayToNS(tempArray)];

        [self setSpotExponent:0.0f];
        [self setSpotCutoff:M_PI];
        [self setConstantAttenuation:1.0f];
        [self setLinearAttenuation:0.0f];
        [self setQuadraticAttenuation:0.0f];
    }

    return self;
}

- (void) dealloc {

    //
    // TODO: release arrays
    //

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

    // http://www.lighthouse3d.com/tutorials/glsl-tutorial/directional-lights-ii/

    //vec4 H = normalize( viewDir - lightDir );

    // http://www.lighthouse3d.com/tutorials/glsl-core-tutorial/glsl-core-tutorial-directional-lights-per-vertex-ii/


    // http://stackoverflow.com/questions/3744038/what-is-half-vector-in-modern-glsl

    // comments taken from Blinn-Phong model wikipedia page

    // need to determine the correct derived calculation that the OpenGL fixed
    // function pipeline is using

    // viewer (V) and the beam from a light-source (L)
    // H = (L + V) / (|L + V|)

    //vec4 H = normalize( lightDir + viewDir );
}
*/
@end

//
// Phong shader for one point light
//
/*
varying vec3 N;
varying vec3 v;
void main(void)
{
    v = vec3(gl_ModelViewMatrix * gl_Vertex);
    N = normalize(gl_NormalMatrix * gl_Normal);
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}


varying vec3 N;
varying vec3 v;
void main (void)
{
    vec3 L = normalize(gl_LightSource[0].position.xyz - v);
    vec3 E = normalize(-v); // we are in Eye Coordinates, so EyePos is (0,0,0)
    vec3 R = normalize(-reflect(L,N));

    //calculate Ambient Term:
    vec4 Iamb = gl_FrontLightProduct[0].ambient;

    //calculate Diffuse Term:
    vec4 Idiff = gl_FrontLightProduct[0].diffuse * max(dot(N,L), 0.0);
    Idiff = clamp(Idiff, 0.0, 1.0);

    // calculate Specular Term:
    vec4 Ispec = gl_FrontLightProduct[0].specular
    * pow(max(dot(R,E),0.0),0.3*gl_FrontMaterial.shininess);
    Ispec = clamp(Ispec, 0.0, 1.0);
    // write Total Color:
    gl_FragColor = gl_FrontLightModelProduct.sceneColor + Iamb + Idiff + Ispec;
}
*/

//
// multiple lights (use same vertex shader)
//
/*
varying vec3 vN;
varying vec3 v;
#define MAX_LIGHTS 3
void main (void)
{
    vec3 N = normalize(vN);
    vec4 finalColor = vec4(0.0, 0.0, 0.0, 0.0);

    for (int i=0; i<MAX_LIGHTS; ++i)
    {
        vec3 L = normalize(gl_LightSource[i].position.xyz - v);
        vec3 E = normalize(-v); // we are in Eye Coordinates, so EyePos is (0,0,0)
        vec3 R = normalize(-reflect(L,N));

        //calculate Ambient Term:
        vec4 Iamb = gl_FrontLightProduct[i].ambient;
        //calculate Diffuse Term:
        vec4 Idiff = gl_FrontLightProduct[i].diffuse * max(dot(N,L), 0.0);
        Idiff = clamp(Idiff, 0.0, 1.0);

        // calculate Specular Term:
        vec4 Ispec = gl_FrontLightProduct[i].specular
        * pow(max(dot(R,E),0.0),0.3*gl_FrontMaterial.shininess);
        Ispec = clamp(Ispec, 0.0, 1.0);

        finalColor += Iamb + Idiff + Ispec;
    }

    // write Total Color:
    gl_FragColor = gl_FrontLightModelProduct.sceneColor + finalColor;
}
*/


@implementation NFLightGroup

@end
