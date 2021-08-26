#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01

out vec4 FragColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

mat2 Rot(float a)
{
    float c = cos(a);
    float s = sin(a);
    return mat2(c, -s, s, c);
}

float sdSphere(vec3 p, vec3 s, float r)
{
    return length(p - s) - r;
}

float sdCapsule (vec3 p, vec3 a, vec3 b, float r)
{
    vec3 ab = b-a;
    vec3 ap = p-a;
    float t = dot(ab, ap) / dot(ab, ab);
    t = clamp(t, 0., 1.);
    vec3 c = a + t*ab;
    return length(p-c) - r;
}

float sdTaurus (vec3 p, vec2 r)
{
    float x = length(p.xz) - r.x;
    return length(vec2(x, p.y)) - r.y;
}

float sdBox(vec3 p, vec3 s)
{
    return length(max(abs(p)-s, 0.));
}

float GetDist(vec3 p) // Calculate distance of all geometry
{
    float sphereDist = sdSphere(p, vec3(0, 3, 5), 0.5);
    float planeDist = p.y;
    float capsuleDist = sdCapsule(p, vec3(0, 2, 5), vec3(1, 2, 6), .2);
    float taurusDist = sdTaurus(p-vec3(0, 1, 6), vec2(1.5, .4));
    vec3 bp = p;
    bp -= vec3(-1, 2, 4); // translation
    bp.xz *= Rot(u_time);      // rotation
    float boxDist = sdBox(bp, vec3(.2,.2,.2));
    float d = min(capsuleDist, planeDist);
    d = min(d, taurusDist);
    d = min(d, sphereDist);
    d = min(d, boxDist);
    return d;
}

float RayMarching(vec3 ro, vec3 rd) //Ray marching algorithm
{
    float d0 = 0.;
    for(int i = 0; i < MAX_STEPS; i++)
    {
        vec3 p = ro + rd*d0;
        float dS = GetDist(p);
        d0 += dS;
        if (d0 > MAX_DIST || dS < SURF_DIST) break; 
    }
    return d0;
}

vec3 GetNormal(vec3 p)
{
    float d = GetDist(p);
    vec2 e = vec2(.01, 0);
    vec3 n = d - vec3(GetDist(p-e.xyy), GetDist(p-e.yxy), GetDist(p-e.yyx));
    return normalize(n);
}

float getLight(vec3 p)
{
    vec3 lightPos = vec3(1, 5, 2);
    lightPos.xz += vec2(sin(u_time), cos(u_time))*2.;
    vec3 l = normalize(lightPos - p);
    vec3 n = GetNormal(p);
    float dif = clamp(dot(n, l), 0., 1.);
    float d = RayMarching(p + n*SURF_DIST*1.2, l);
    if (d < length(lightPos - p)) dif *= .1;
    return dif;
}

void main()
{
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 mouse = 2.0 * (u_mouse.xy - 0.5 * u_resolution.xy) / u_resolution.y + vec2(0.6);

    vec3 ro = vec3(mouse.x, mouse.y * 2.0 + 2.0, 0);
    vec3 rd = normalize(vec3(uv.x, uv.y, 1));

    float d = RayMarching(ro, rd);

    vec3 p = ro + rd * d; 
    float dif = getLight(p);
    vec3 c = vec3(dif);
    vec3 color = vec3(cos(u_time), sin(u_time), cos(u_time)/2.);
    c += color/10.;
    
    float a = 0.0;
    if (length(mouse - uv) < 0.04) a = 1.0;
    c.r += a;

    FragColor = vec4(c, 1.0);
}
