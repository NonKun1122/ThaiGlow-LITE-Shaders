#version 120
uniform sampler2D texture;
varying vec2 uv; varying vec4 col;
void main() { gl_FragColor = texture2D(texture, uv) * col; }
