varying vec3 v_normal;
#ifdef VERTEX
attribute vec4 VertexWeight;
attribute vec4 VertexBone;
attribute vec3 VertexNormal;
uniform mat4 u_camera, u_model, u_proj;
uniform mat4 u_pose[100];
vec4 position(mat4 _, vec4 vertex) {
	mat4 skeleton = u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
		u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
		u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
		u_pose[int(VertexBone.w*255.0)] * VertexWeight.w;
	mat4 transform = u_camera * u_model * skeleton;
	v_normal = mat3(transform) * VertexNormal;
	return u_proj * transform * vertex;
}
#endif
#ifdef PIXEL
uniform vec3 u_light;
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc) {
	float shade = max(0, dot(v_normal, u_light)) + 0.25;
	vec3 texturecolor = shade * Texel(tex, uv).rgb;
	//vec3 texturecolor = vec3(shade);
	return vec4(texturecolor * color.rgb, 1.0);
}
#endif