//
//  DefaultModel.fsh
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
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
// TODO: add support for shadow maps
//


uniform vec3 viewPos;

//uniform bool useBlinnSpecular;

uniform material_t material;

uniform directionalLight_t directionalLight;
uniform pointLight_t pointlight;
uniform spotLight_t spotLight;

in vec3 f_position;
in vec3 f_normal;
in vec2 f_texcoord;

//
// TODO: light space vector needs to have multiple inputs, one per each light
//
in vec4 f_posLightSpace;


out vec4 color;


vec3 calc_directional_light(directionalLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir);
vec3 calc_point_light(pointLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir);
vec3 calc_spot_light(spotLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir);


//
// TODO: add layout qualifiers
//


//
// NOTE: if passing the material struct sampler2D to a function must use in qualifer
//
//vec4 add(in sampler2D tex) {
//    return vec4(texture(tex, texcoords));
//}


vec3 calc_directional_light(directionalLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir) {
    vec3 lightDir = normalize(-light.direction);
    vec3 norm = normalize(normal);

    // ambient
    vec3 ambient = light.ambient * material.ambient * vec3(texture(material.diffuseMap, f_texcoord));

    // diffuse
    float diff = max(dot(norm, lightDir), 0.0f);
    //vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuseMap, f_texcoord));
    vec3 diffuse = light.diffuse * (diff * material.diffuse * texture(material.diffuseMap, f_texcoord).xyz);

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

    return (ambient + diffuse + specular);
}

vec3 calc_point_light(pointLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir) {
    vec3 lightDir = normalize(light.position - fragPosition);
    vec3 norm = normalize(normal);

    // ambient
    vec3 ambient = light.ambient * material.ambient * texture(material.diffuseMap, f_texcoord).xyz;

    // diffuse
    float diff = max(dot(norm, lightDir), 0.0f);
    vec3 diffuse = light.diffuse * (diff * material.diffuse * texture(material.diffuseMap, f_texcoord).xyz);

    // specular
    //
    // TODO: add option to use Blinn specular
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

    vec3 specular = light.specular * (spec * material.specular);

    // attenuation
    float distance = length(light.position - fragPosition);
    float attenuation = 1.0f / (light.constant - light.linear * distance + light.quadratic * (distance * distance));
    ambient  *= attenuation;
    diffuse  *= attenuation;
    specular *= attenuation;

    return(ambient + diffuse + specular);
}

vec3 calc_spot_light(spotLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir) {
    vec3 lightDir = normalize(light.position - fragPosition);
    vec3 norm = normalize(normal);

    // ambient
    vec3 ambient = light.ambient * material.ambient * texture(material.diffuseMap, f_texcoord).xyz;

    // diffuse
    float diff = max(dot(norm, lightDir), 0.0f);
    vec3 diffuse = light.diffuse * (diff * material.diffuse * texture(material.diffuseMap, f_texcoord).xyz);

    // specular
    //
    // TODO: add option to use Blinn specular
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

    return(ambient + diffuse + specular);
}

void main() {
    vec3 viewDir = normalize(viewPos - f_position);

    vec3 result = vec3(0);


#define USE_DIRECTIONAL_LIGHT  1
#define USE_POINT_LIGHT        1
#define USE_SPOT_LIGHT         1


#if USE_DIRECTIONAL_LIGHT
    result += calc_directional_light(directionalLight, f_normal, f_position, viewDir);
#else
    vec3 directionalOutput = calc_directional_light(directionalLight, f_normal, f_position, viewDir);
    directionalOutput = result;
#endif


#if USE_POINT_LIGHT
    result += calc_point_light(pointlight, f_normal, f_position, viewDir);
#else
    vec3 pointOutput = calc_point_light(pointlight, f_normal, f_position, viewDir);
    pointOutput = result;
#endif

#if USE_SPOT_LIGHT
    result += calc_spot_light(spotLight, f_normal, f_position, viewDir);
#else
    vec3 spotOutput = calc_spot_light(spotLight, f_normal, f_position, viewDir);
    spotOutput = result;
#endif

    //
    // TODO: add gamma correction (find some assets with a rendered frame for reference), note that
    //       currently using an SRGB framebuffer which will make the final frame appear roughly gamma
    //       correct with a gamma of 2.2 but will not allow for the user to tweak their gamma
    //
    float gamma = 2.2f;
    result = pow(result, vec3(1.0f/gamma));

    color = vec4(result, 1.0f);
}
