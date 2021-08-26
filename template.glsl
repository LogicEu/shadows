out vec4 FragColor;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

void main() 
{
	vec2 uv = gl_FragCoord.xy / u_resolution.y;
	vec3 color = vec3(uv.x, uv.y, cos(u_time));
	FragColor = vec4(color, 1.0);
}
