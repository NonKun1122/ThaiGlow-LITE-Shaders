#version 120
varying vec2 uv;
varying vec4 col;

void main() {
    gl_Position = ftransform();
    uv  = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    col = gl_Color;
}
