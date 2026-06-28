#version 120
varying vec4 col;
varying vec3 dir;
void main() {
    gl_Position = ftransform();
    col = gl_Color;
    dir = gl_Vertex.xyz;
}
