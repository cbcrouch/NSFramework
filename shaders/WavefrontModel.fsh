//
//  WavefrontModel.fsh
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410



/*
 Ns 10.0000       // specular coefficient
 Ni 1.5000        // optical density (also known as index of refraction)
 Tr 0  0          // transparency
 illum 2          // illumination model
 Ka 1 1 1         // ambient color
 Kd 1 1 1         // diffuse color
 Ks 0.2 0.2 0.2   // specular color
 Ke 0 0 0         // emissive color
 */


// illumination model definition breakdown
// 0: color on and ambient off
// 1: color on and ambient on
// 2: highlight on
// 3: reflection on and ray trace on
// 4: transparency: glass on // reflection: ray trace on
// 5: reflection: fresnel on and ray trace on
// 6: transparency: refraction on // reflection: fresnel off and ray trace on
// 7 transparency: refraction on // reflection: fresnel on and ray trace on
// 8: reflection on and ray trace off
// 9: transparency: glass on // reflection: ray trace off
// 10: casts shadows onto invisible surfaces


/*
Term	Definition

Ft	Fresnel reflectance
Ft	Fresnel transmittance

Ia	ambient light
I	light intensity
Ir	intensity from reflected direction (reflection map and/or ray tracing)
It	intensity from transmitted direction
Ka	ambient reflectance
Kd	diffuse reflectance
Ks	specular reflectance
Tf	transmission filter

Vector	Definition

H	unit vector bisector between L and V
L	unit light vector
N	unit surface normal
V	unit view vector
*/


//
// TODO: can't have samplers in a UBO
//
/*
layout(std140) uniform UBOWavefrontMat {
    float Ns; // specular coefficient
    float Ni; // optical density (also known as index of refraction)

    float d;
    //BOOL dHalo;

    float Tr; // transparency

    vec4 Tf;  // transmission factor

    vec4 Ka;  // ambient color
    vec4 Kd;  // diffuse color
    vec4 Ks;  // specular color

    vec4 Ke;  // emissive color

    sampler2D map_Ka; // ambient color texture map (will be same as diffuse most of the time)
    sampler2D map_Kd; // diffuse color texture map
    sampler2D map_Ks; // specular color texture map
    sampler2D map_Ns; // specular highlight component

    sampler2D map_Tr; // transparency map
    
    sampler2D map_bump;
    sampler2D map_disp;
    sampler2D map_decalT;
} UBOWavefrontMat;
*/


//
// TODO: need a light definition
//

// Ia - vec4
// I  - float
// Ir - sampler2D
// It - float


// H  - vec4
// L  - vec4
// N  - vec4
// V  - vec4


//
// #define IN_POSITION 0
// layout(location = IN_POSITION) in vec4 f_vertex;
//
in vec4 f_vertex;
in vec4 f_normal;
in vec3 f_texcoord;

out vec4 fragColor;



// Fresnel reflectance
vec4 Fr(vec4 NV, vec4 Ks, float Ns) {
    return vec4(1.0, 0.0, 0.0, 1.0);
}

// Fresnel transmittance
vec4 Ft(vec4 NV, vec4 invKs, float Ns) {
    return vec4(1.0, 0.0, 0.0, 1.0);
}



subroutine vec4 illum_t();
subroutine uniform illum_t IllumModel;

//...

uniform sampler2D Kd;

subroutine(illum_t)
vec4 IllumModel0() {
    // 0  This is a constant color illumination model.  The color is the
    // specified Kd for the material.  The formula is:
    //
    //  color = Kd

    return vec4(1.0, 0.0, 0.0, 1.0);
    //return texture(Kd, f_texcoord.xy);
}

subroutine(illum_t)
vec4 IllumModel1() {
    // 1  This is a diffuse illumination model using Lambertian shading. The
    // color includes an ambient constant term and a diffuse shading term for
    //  each light source.  The formula is

    //  color = KaIa + Kd { SUM j=1..ls, (N * Lj)Ij }

    return vec4(1.0, 1.0, 0.0, 1.0);
}

subroutine(illum_t)
vec4 IllumModel2() {
    // 2  This is a diffuse and specular illumination model using Lambertian
    // shading and Blinn's interpretation of Phong's specular illumination
    // model (BLIN77).  The color includes an ambient constant term, and a
    // diffuse and specular shading term for each light source.  The formula
    //  is:

    //  color = KaIa
    //  + Kd { SUM j=1..ls, (N*Lj)Ij }
 	//  + Ks { SUM j=1..ls, ((N*Hj)^Ns)Ij }

    return vec4(0.0, 1.0, 0.0, 1.0);
}


void main (void) {
    // to use the illumination subroutine
    fragColor = IllumModel();
}
