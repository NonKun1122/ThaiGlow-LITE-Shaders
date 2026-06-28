#version 120
uniform sampler2D gcolor;
varying vec2 uv;
void main() {
    vec3 c = texture2D(gcolor, uv).rgb;

    // Vignette เบามาก
    vec2 v = uv * 2.0 - 1.0;
    c *= 0.93 + 0.07 * smoothstep(1.0, 0.2, dot(v * 0.35, v * 0.35));

    gl_FragColor = vec4(clamp(c, 0.0, 1.0), 1.0);
}
