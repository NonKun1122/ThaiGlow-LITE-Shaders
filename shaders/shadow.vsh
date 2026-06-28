#version 120

varying vec2 texCoord;
varying vec4 color;

void main() {
    texCoord = gl_MultiTexCoord0.st;
    color = gl_Color;
    gl_Position = ftransform();
}
