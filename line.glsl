out vec4 FragColor;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define MARKER_RADIUS 12.5
#define THICCNESS 10.0

void main(void)
{
    FragColor = vec4(vec3(0.0), 1.0);
    vec2 p1 = vec2(20.0, 20.0);
    vec2 p2 = u_mouse;
    vec2 p3 = gl_FragCoord.xy;
        
    FragColor.r = float(length(p3 - p1) < MARKER_RADIUS);
    FragColor.r += float(length(gl_FragCoord.xy - p2) < MARKER_RADIUS);

    vec2 p12 = p2 - p1;
    vec2 p13 = p3 - p1;

    float d = dot(p12, p13) / length(p12);
    vec2 p4 = p1 + normalize(p12) * d;
    FragColor.g =   float(length(p4 - p3) < THICCNESS) * 
                    float(length(p4 - p1) <= length(p12)) * 
                    float(length(p4 - p2) <= length(p12));
}
