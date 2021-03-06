//
//  DefaultModel.fsh
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#version 410


struct material_t {
    //
    // TODO: remove ambient and replace diffuse and specular with mapped values, for objects that
    //       don't have one or the other will need to generate one
    //
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    // diffuse and specular will be color scalars, i.e. how much of each channel to pass through from
    // the respective maps, this is primarily for debugging visualization
    //vec3 diffuseScalar;
    //float specularScalar;


    // strength of the specular reflection
    float shininess;

    // sampler2D is an opaque type, they can be decalred as members of a struct, but if so, then the struct
    // can only be used to declare a uniform variable (they cannot be part of a buffer-backed interface block
    // or an input/output variable)
    sampler2D diffuseMap;
    sampler2D specularMap;
};

struct directionalLight_t {
    vec3 direction;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct pointLight_t {
    vec3 position;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};

struct spotLight_t {
    vec3 position;
    vec3 direction;

    float innerCutOff;
    float outerCutOff;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};

//
// TODO: rename to camera position
//
uniform vec3 viewPos;

//
// TODO: add option to use Blinn specular
//
//uniform bool useBlinnSpecular;

uniform material_t material;

uniform directionalLight_t directionalLight;
uniform pointLight_t pointlight;
uniform spotLight_t spotLight;


uniform sampler2D shadowMap;
uniform sampler2D spotShadowMap;
uniform samplerCube pointShadowMap;

uniform bool useDefaultCubeMap;
uniform samplerCube defaultCubeMap;

//
// TODO: add layout qualifiers
//

in vec3 f_position;
in vec3 f_normal;
in vec2 f_texcoord;

//
// TODO: light space vector needs to have multiple inputs, one per each light
//
in vec4 f_posLightSpace;
in vec4 f_posSpotLightSpace;

out vec4 color;

//
// TODO: pass in params for light calculations through a common struct
//
/*
struct lighting_t {
    vec3 normal;
    vec3 fragPosition;
    vec3 viewDir;
    float shadow;

    vec4 texelColor;
};
*/
vec3 calc_directional_light(directionalLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir, float shadow);
vec3 calc_point_light(pointLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir, float shadow);
vec3 calc_spot_light(spotLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir, float shadow);


//
// TODO: get environment map displaying without lighting (use debugging tools to verify that cube map
//       data is valid when the attempt to render the frame)
//
vec4 cubemap_reflect() {
    vec3 I = normalize(f_position - viewPos);
    vec3 R = reflect(I, normalize(f_normal));
    return texture(defaultCubeMap, R);
}


//
// NOTE: if passing the material struct sampler2D to a function must use in qualifer
//
//vec4 add(in sampler2D tex) {
//    return vec4(texture(tex, texcoords));
//}


vec3 calc_directional_light(directionalLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir, float shadow) {
    vec3 lightDir = normalize(-light.direction);
    vec3 norm = normalize(normal);

    vec3 texel = texture(material.diffuseMap, f_texcoord).xyz;
    if (useDefaultCubeMap) {
        //texel = cubemap_reflect().xyz;
        texel = vec3(0.0, 0.75, 0.0);
    }

    // ambient
    vec3 ambient = light.ambient * material.ambient * texel;

    // diffuse
    float diff = max(dot(norm, lightDir), 0.0f);
    vec3 diffuse = light.diffuse * (diff * material.diffuse * texel);



    //
    // TODO: no specular highlight applied to back-facing geometry for the directional light
    //

    // specular
    //
    // TODO: make the useBlinn boolean a uniform and allow it to be set with a key press so
    //       can switch back and forth between Phong specular and Blinn-Phong specular claculation
    //
    bool useBlinn = false;

    float spec = 0.0f;
    if (useBlinn) {
        vec3 halfwayDir = normalize(lightDir + viewDir);
        spec = pow(max(dot(norm, halfwayDir), 0.0f), 2.0f * material.shininess);
    }
    else {
        vec3 reflectDir = reflect(-lightDir, norm);
        spec = pow(max(dot(viewDir, reflectDir), 0.0f), material.shininess);
    }

    vec3 specular = light.specular * spec * material.specular;




    return (ambient + ((1.0 - shadow) * (diffuse + specular)));
}

vec3 calc_point_light(pointLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir, float shadow) {
    vec3 lightDir = normalize(light.position - fragPosition);
    vec3 norm = normalize(normal);

    //
    // TODO: cleaner cutoff lighting if surface is facing away from the light direction
    //
    if(dot(lightDir, norm) < 0.0f) {
        return vec3(0.0f);
    }

    //
    // TODO: have on function that is responsible for getting the fragment color that can then be
    //       passed into the lighting functions
    //
    vec3 texel = texture(material.diffuseMap, f_texcoord).xyz;
    if (useDefaultCubeMap) {
        //texel = cubemap_reflect().xyz;
        texel = vec3(0.0, 0.75, 0.0);
    }


    // ambient
    vec3 ambient = light.ambient * material.ambient * texel;

    // diffuse
    float diff = max(dot(norm, lightDir), 0.0f);
    vec3 diffuse = light.diffuse * (diff * material.diffuse * texel);

    // specular
    bool useBlinn = false;

    float spec = 0.0f;
    if (useBlinn) {
        vec3 halfwayDir = normalize(lightDir + viewDir);
        spec = pow(max(dot(norm, halfwayDir), 0.0f), 2.0f * material.shininess);
    }
    else {
        vec3 reflectDir = reflect(-lightDir, norm);
        spec = pow(max(dot(viewDir, reflectDir), 0.0f), material.shininess);
    }

    vec3 specular = light.specular * (spec * material.specular);

    // attenuation
    float distance = length(light.position - fragPosition);
    float attenuation = 1.0f / (light.constant - light.linear * distance + light.quadratic * (distance * distance));
    ambient  *= attenuation;
    diffuse  *= attenuation;
    specular *= attenuation;

    return (ambient + ((1.0 - shadow) * (diffuse + specular)));
}

vec3 calc_spot_light(spotLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir, float shadow) {
    vec3 lightDir = normalize(light.position - fragPosition);
    vec3 norm = normalize(normal);

    //
    // TODO: cleaner cutoff lighting if surface is facing away from the light direction
    //
    if(dot(lightDir, norm) < 0.0f) {
        return vec3(0.0f);
    }

    vec3 texel = texture(material.diffuseMap, f_texcoord).xyz;
    if (useDefaultCubeMap) {
        //texel = cubemap_reflect().xyz;
        texel = vec3(1.0, 0.0, 1.0);
    }

    // ambient
    vec3 ambient = light.ambient * material.ambient * texel;

    // diffuse
    float diff = max(dot(norm, lightDir), 0.0f);
    vec3 diffuse = light.diffuse * (diff * material.diffuse * texel);

    // specular
    bool useBlinn = false;

    float spec = 0.0f;
    if (useBlinn) {
        vec3 halfwayDir = normalize(lightDir + viewDir);
        spec = pow(max(dot(norm, halfwayDir), 0.0f), 2.0f * material.shininess);
    }
    else {
        vec3 reflectDir = reflect(-lightDir, norm);
        spec = pow(max(dot(viewDir, reflectDir), 0.0f), material.shininess);
    }

    vec3 specular = light.specular * (spec * material.specular);

    // spotlight (soft edges)
    float theta = dot(lightDir, normalize(-light.direction));
    float epsilon = (light.innerCutOff - light.outerCutOff);
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0f, 1.0f);
    diffuse *= intensity;
    specular *= intensity;
    ambient *= intensity;

    //
    // TODO: derive correct attenuation
    //

    // attenuation
    float distance = length(light.position - fragPosition);

    float attenuation = 1.0f / (light.constant + (light.linear * distance) + light.quadratic * (distance * distance));
    //float attenuation = 1.0f / (light.constant - light.linear * distance + light.quadratic * (distance * distance));

    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;


    return (ambient + ((1.0 - shadow) * (diffuse + specular)));
}

//
// NOTE: this is for directional lights only (will also work for the spot light)
//
float shadow_calculation(vec4 frag_pos_light_space, vec3 normal, vec3 lightDir, sampler2D depthMap) {
    // perspective divide and transform to [0, 1] range
    vec3 projCoords = frag_pos_light_space.xyz / frag_pos_light_space.w;
    projCoords = projCoords * 0.5 + 0.5;

    if(projCoords.z > 1.0f) {
        return 0.0f;
    }


    float currentDepth = projCoords.z;

    //
    // NOTE: was originally using a maximum bias of 0.05 and a minimum of 0.005 but this was casuing
    //       the shadow on the sphere to get clipped around the base when the bottom most vertex of
    //       the sphere was shared with the "ground" plane (should revisit these values)
    //
    //float bias = max(0.00125 * (1.0 - dot(f_normal, lightDir)), 0.0005);

    float bias = 0.00005;

    //
    // TODO: keep in mind when using PCF it may eliminate self shadowing
    //
#define USE_SIMPLE_PCF 0

#if USE_SIMPLE_PCF
    float shadowVal = 0.0;
    vec2 texelSize = 1.0 / textureSize(depthMap, 0);
    for (int x=-1; x<2; ++x) {
        for(int y=-1; y<2; ++y) {
            float pcfDepth = texture(depthMap, projCoords.xy + vec2(x,y)*texelSize).r;
            shadowVal += currentDepth - bias > pcfDepth ? 1.0 : 0.0;
        }
    }
    shadowVal /= 9.0;
#else
    // get closet depth value from light's perspective using [0,1] range frag_pos_light_space as coords
    float closestDepth = texture(depthMap, projCoords.xy).r;

    // check wheter current frag pos is in shadow
    float shadowVal = currentDepth - bias > closestDepth ? 1.0 : 0.0;
#endif

    return shadowVal;
}

float point_shadow_calculation(pointLight_t light, vec3 fragPosition) {
    vec3 fragToLight = fragPosition - light.position;
    float closestDepth = texture(pointShadowMap, fragToLight).r;

    //
    // TODO: make far plane a uniform
    //
    float farPlane = 100.0f;

    closestDepth *= farPlane;
    float currentDepth = length(fragToLight);

    //float bias = 0.05;
    float bias = 0.00125;

    float shadow = currentDepth - bias > closestDepth ? 1.0 : 0.0;

    return shadow;
}

void main() {
    float shadowVal = shadow_calculation(f_posLightSpace, f_normal, normalize(-directionalLight.direction), shadowMap);
    float pointShadowVal = point_shadow_calculation(pointlight, f_position);
    float spotShadowVal = shadow_calculation(f_posSpotLightSpace, f_normal, normalize(-spotLight.direction), spotShadowMap);

    vec3 viewDir = normalize(viewPos - f_position);
    vec3 result = vec3(0);

#define USE_DIRECTIONAL_LIGHT  1
#define USE_POINT_LIGHT        1
#define USE_SPOT_LIGHT         1

#if USE_DIRECTIONAL_LIGHT
    result += calc_directional_light(directionalLight, f_normal, f_position, viewDir, shadowVal);
#else
    vec3 directionalOutput = calc_directional_light(directionalLight, f_normal, f_position, viewDir, shadowVal);
    directionalOutput = result;
#endif

#if USE_POINT_LIGHT
    result += calc_point_light(pointlight, f_normal, f_position, viewDir, pointShadowVal);
#else
    vec3 pointOutput = calc_point_light(pointlight, f_normal, f_position, viewDir, pointShadowVal);
    pointOutput = result;
#endif

#if USE_SPOT_LIGHT
    result += calc_spot_light(spotLight, f_normal, f_position, viewDir, spotShadowVal);
#else
    vec3 spotOutput = calc_spot_light(spotLight, f_normal, f_position, viewDir, spotShadowVal);
    spotOutput = result;
#endif

    //
    // TODO: add gamma correction (find some assets with a rendered frame for reference), and
    //       setup to allow for the user to tweak their gamma
    //
    float gamma = 2.2f;
    result = pow(result, vec3(1.0f/gamma));

    color = vec4(result, 1.0f);


    //
    // TODO: get environment map displaying without lighting
    //

    float throwaway = 0.0;
    if (useDefaultCubeMap) {
        //color = cubemap_reflect();
        throwaway = cubemap_reflect().r;
    }

}
