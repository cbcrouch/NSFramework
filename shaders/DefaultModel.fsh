//
//  DefaultModel.fsh
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
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


uniform vec3 viewPos;

//uniform bool useBlinnSpecular;

uniform material_t material;

uniform directionalLight_t directionalLight;
uniform pointLight_t pointlight;
uniform spotLight_t spotLight;

in vec3 f_position;
in vec3 f_normal;
in vec2 f_texcoord;

out vec4 color;


vec3 calc_directional_light(directionalLight_t light, vec3 normal, vec3 viewDir);
vec3 calc_point_light(pointLight_t light, vec3 normal, vec3 fragPosition, vec3 viewDir);
vec3 calc_spot_light(spotLight_t light, vec3 normal, vec3 viewDir);


//
// TODO: add layout qualifiers
//


//
// NOTE: if passing the material struct sampler2D to a function must use in qualifer
//
//vec4 add(in sampler2D tex) {
//    return vec4(texture(tex, texcoords));
//}


vec3 calc_directional_light(directionalLight_t light, vec3 normal, vec3 viewDir) {
    vec3 lightDir = normalize(-light.direction);
    vec3 norm = normalize(normal);

    // ambient
    vec3 ambient = light.ambient * vec3(texture(material.diffuseMap, f_texcoord));

    // diffuse
    float diff = max(dot(norm, lightDir), 0.0f);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuseMap, f_texcoord));

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

    vec3 specular = light.specular * (spec * material.specular);

    // attenuation
    float distance = length(light.position - fragPosition);
    float attenuation = 1.0f / (light.constant - light.linear * distance + light.quadratic * (distance * distance));

    ambient  *= attenuation;
    diffuse  *= attenuation;
    specular *= attenuation;

    return(ambient + diffuse + specular);
}

vec3 calc_spot_light(spotLight_t light, vec3 normal, vec3 viewDir) {

    //
    // TODO: implement
    //

    //

    return vec3(0,0,0);
}

void main() {
    vec3 viewDir = normalize(viewPos - f_position);
    vec3 result = calc_point_light(pointlight, f_normal, f_position, viewDir);

#if 0
    result += calc_directional_light(directionalLight, f_normal, viewDir);
#else
    vec3 directionalOutput = calc_directional_light(directionalLight, f_normal, viewDir);
    directionalOutput = result;
#endif


#if 0
    result += calc_spot_light(spotLight, f_normal, viewDir);
#else
    vec3 spotOutput = calc_spot_light(spotLight, f_normal, viewDir);
    spotOutput = result;
#endif

    //
    // TODO: add gamma correction (find some assets with a rendered frame for reference), note that
    //       currently using an SRGB framebuffer which will make the final frame appear roughly gamma
    //       correct with a gamma of 2.2 but will not allow for the user to tweak their gamma
    //
    //float gamma = 2.2f;
    //result = pow(result, vec3(1.0f/gamma));

    color = vec4(result, 1.0f);
}
