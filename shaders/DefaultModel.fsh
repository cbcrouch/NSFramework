//
//  DefaultModel.fsh
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#version 410


struct material_t {
    //
    // TODO: according to the GLSL spec cannot include sampler2D in a struct (some drivers will allow it)
    //       will need to remove these to ensure shader will work with more driver/hardware combinations
    //
    sampler2D diffuse;
    sampler2D specular;

    float     shininess;
};

struct light_t {
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};


uniform vec3 viewPos;

uniform material_t material;
uniform light_t light;

in vec3 f_position;
in vec3 f_normal;
in vec2 f_texcoord;

out vec4 color;


//
// TODO: setup lighting subroutines
//
subroutine vec4 lightingFunc(vec3 pos, vec3 norm, vec2 texcoord);
subroutine uniform lightingFunc LightingFunction;


//subroutine(lightingFunc)
//vec4 light_subroutine(vec3 pos, vec3 norm, vec2 texcoord)
//{
//    color = vec4(1.0f); // Set all 4 vector values to 1.0f
//}

//subroutine(lightingFunc)
//vec4 phong_subroutine(vec3 pos, vec3 norm, vec2 texcoord)
//{
//}


void main()
{
    // Ambient
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, f_texcoord));

    // Diffuse
    vec3 norm = normalize(f_normal);
    vec3 lightDir = normalize(light.position - f_position);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, f_texcoord));

    // Specular
    vec3 viewDir = normalize(viewPos - f_position);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specular * spec * vec3(texture(material.specular, f_texcoord));

    color = vec4(ambient + diffuse + specular, 1.0f);
}
