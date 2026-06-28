#version 120
varying vec2 uv;
varying vec4 col;
varying float bl;

void main() {
    gl_Position = ftransform();
    uv  = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    col = gl_Color;
    vec2 lm = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    bl = lm.x;
}
