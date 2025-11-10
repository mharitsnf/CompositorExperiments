#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

// Our push constant
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	vec2 pixel_size;
} params;

const int pixel_size_default = 5;

// The code we want to execute in each invocation
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);

	// Prevent reading/writing out of bounds.
	if (uv.x >= size.x || uv.y >= size.y) {
		return;
	}

	// Pixelization
	float x = int(uv.x) % int(params.pixel_size.x);
	float y = int(uv.y) % int(params.pixel_size.x);

	x = floor(int(params.pixel_size.x) / 2.0) - x;
	y = floor(int(params.pixel_size.x) / 2.0) - y;

	x = uv.x + x;
	y = uv.y + y;

	// Read from our color buffer.
	vec4 pixelated_image = imageLoad(color_image, ivec2(x, y));

	// Write back to our color buffer.
	imageStore(color_image, uv, pixelated_image);
}