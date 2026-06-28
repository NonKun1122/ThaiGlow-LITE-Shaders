#version 120

uniform sampler2D texture;
uniform int worldTime;

varying vec2 uv;
varying vec4 col;

#ifndef NIGHT_BRIGHTNESS
#define NIGHT_BRIGHTNESS 0.6
#endif

void main() {
    vec4 albedo = texture2D(texture, uv) * col;
    if (albedo.a < 0.1) discard;

    float tod = mod(float(worldTime), 24000.0) / 24000.0;

    float nightFactor;
    if (tod > 0.55 && tod < 0.95) nightFactor = 1.0;
    else if (tod > 0.45 && tod < 0.55) nightFactor = smoothstep(0.45, 0.55, tod);
    else if (tod > 0.95) nightFactor = 1.0 - smoothstep(0.95, 1.0, tod);
    else nightFactor = 0.0;

    vec3 color = albedo.rgb;

    // Darken hand at night
    color *= mix(1.0, NIGHT_BRIGHTNESS * 0.8, nightFactor);

    gl_FragColor = vec4(color, albedo.a);
}
