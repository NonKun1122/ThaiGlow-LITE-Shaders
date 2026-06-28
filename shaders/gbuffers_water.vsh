#version 120
varying vec2 uv;
varying vec4 col;
varying vec3 norm;
varying vec3 vPos;
varying float bl;
varying float sl;

void main() {
    gl_Position = ftransform();
    uv   = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    col  = gl_Color;
    norm = normalize(gl_NormalMatrix * gl_Normal);
    vPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    vec2 lm = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    bl = lm.x;
    sl = lm.y;
}
