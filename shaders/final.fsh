#version 120
uniform sampler2D gcolor;
varying vec2 uv;
void main() {
    vec3 c = texture2D(gcolor, uv).rgb;
    vec2 v = uv * 2.0 - 1.0;
    c *= 0.97 + 0.03 * smoothstep(1.0, 0.2, dot(v * 0.25, v * 0.25));
    gl_FragColor = vec4(clamp(c, 0.0, 1.0), 1.0);
}
