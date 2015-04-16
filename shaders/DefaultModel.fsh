//
//  DefaultModel.fsh
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#version 410

struct material_t {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

struct light_t {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    vec3 position;
};

uniform vec3 viewPos;
uniform material_t material;
uniform light_t light;


//
// TODO: rename to diffuseTexture
//
uniform sampler2D texSampler;


in vec3 f_position;
in vec3 f_normal;
in vec2 f_texcoord;

out vec4 color;

subroutine vec4 lightingFunc();
subroutine uniform lightingFunc LightingFunction;

subroutine(lightingFunc)
vec4 light_subroutine()
{
    return vec4(1.0f); // set all 4 vector values to 1.0f
}

subroutine(lightingFunc)
vec4 phong_subroutine()
{
    // ambient
    vec3 ambient = light.ambient * material.ambient;

    // diffuse
    vec3 norm = normalize(f_normal);
    vec3 lightDir = normalize(light.position - f_position);
    float diff = max(dot(norm, lightDir), 0.0f);
    vec3 diffuse = light.diffuse * (diff * material.diffuse);

    vec4 diffuseTexel = texture(texSampler, f_texcoord);

    // specular
    vec3 viewDir = normalize(viewPos - f_position);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0f), material.shininess);
    vec3 specular = light.specular * (spec * material.specular);

    vec3 result = ambient + diffuse + specular;
    return vec4(result, 1.0f);
}

void main()
{
    color = LightingFunction();
}
