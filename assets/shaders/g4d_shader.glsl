// Camera data
struct Camera {
	mat4 projection_matrix;
	mat4 view_matrix;
	vec4 position;
};
uniform Camera camera;

// Model data
struct Model {
	mat4 matrix;
	vec4 color;
	bool is_animated;
	mat4 pose[100];
};
uniform Model model;


#ifdef VERTEX
attribute vec4 VertexWeight;
attribute vec4 VertexBone;
attribute vec3 VertexNormal;

vec4 position(mat4 transform_projection, vec4 initial_vertex_position)
{

	if (model.is_animated) {
		mat4 skeleton = 
			model.pose[int(VertexBone.x * 255.0)] * VertexWeight.x +
			model.pose[int(VertexBone.y * 255.0)] * VertexWeight.y +
			model.pose[int(VertexBone.z * 255.0)] * VertexWeight.z +
			model.pose[int(VertexBone.w * 255.0)] * VertexWeight.w;

		initial_vertex_position = skeleton * initial_vertex_position;
	}

	return camera.projection_matrix * camera.view_matrix * model.matrix * initial_vertex_position;
}
#endif


#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 texture_color = Texel(texture, texture_coords);
	return texture_color * model.color;
}
#endif
