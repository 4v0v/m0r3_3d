varying vec3 v_normal;


#ifdef VERTEX
attribute vec4 VertexWeight;
attribute vec4 VertexBone;
attribute vec3 VertexNormal;

uniform mat4 u_proj;
uniform mat4 u_camera;
uniform mat4 u_model;

uniform mat4 u_pose[100];

vec4 position(mat4 _, vec4 vertex) {

	mat4 skeleton = 
		u_pose[int(VertexBone.x * 255.0)] * VertexWeight.x +
		u_pose[int(VertexBone.y * 255.0)] * VertexWeight.y +
		u_pose[int(VertexBone.z * 255.0)] * VertexWeight.z +
		u_pose[int(VertexBone.w * 255.0)] * VertexWeight.w;

	vertex = skeleton * vertex;

	return u_proj * u_camera * u_model * vertex;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
	vec4 texcolor = Texel(tex, texture_coords);
	return texcolor * color;
}
#endif