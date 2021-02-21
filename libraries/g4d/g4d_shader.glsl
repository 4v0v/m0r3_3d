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
};
uniform Model model;


#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 initial_vertex_position)
{
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
