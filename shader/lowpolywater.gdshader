shader_type spatial;
render_mode blend_mix, cull_disabled;


uniform vec4 out_col : source_color = vec4(0.2, 0.4, 0.8, 1.0); 
uniform float amount : hint_range(0.2,1.5) = 0.8;
uniform float beer_factor : hint_range(0.01, 1.0) = 0.2; 
uniform float metallic : hint_range(0.0, 1.0) = 0.7;
uniform float roughness : hint_range(0.0, 1.0) = 0.3;
uniform float specular : hint_range(0.0, 1.0) = 0.5;


uniform sampler2D screen_depth : hint_depth_texture;


float gen_offset(float x, float z, float val1, float val2, float time){
    float spd=1.0;

    float radX = ((mod(x+z*x*val1,amount)/amount)+(time*spd)*mod(x*0.8+z,1.5))*2.0*3.14159265359;
    float radZ = ((mod(val2*(z*x+x*z),amount)/amount)+(time*spd)*2.0*mod(x,2.0))*2.0*3.14159265359;

    return amount*0.5*(sin(radZ)+cos(radX));
}

vec3 apply_dist(vec3 vertex, float time){
    float xd = gen_offset(vertex.x,vertex.z,0.2,0.1,time);
    float yd = gen_offset(vertex.x,vertex.z,0.1,0.3,time);
    float zd = gen_offset(vertex.x,vertex.z,0.15,0.2,time);

    return vertex+vec3(xd,yd,zd);
}

// --- Fonction Vertex ---
void vertex(){
    VERTEX = apply_dist(VERTEX, TIME*0.1);
}


void fragment(){

    ALBEDO = out_col.xyz;
    METALLIC = metallic;
    SPECULAR = specular;
    ROUGHNESS = roughness;
    NORMAL = normalize(cross( dFdx(VERTEX), dFdy(VERTEX) ));
    

    float raw_depth = texture(screen_depth, SCREEN_UV).r;
    

    float background_view_z = PROJECTION_MATRIX[3][2] / (raw_depth * 2.0 - 1.0 + PROJECTION_MATRIX[2][2]);
    

    float water_surface_view_z = -VERTEX.z;


    float water_depth = background_view_z - water_surface_view_z; 


    water_depth = max(0.0, water_depth); 

    float absorption = exp(-water_depth * beer_factor);
    

}