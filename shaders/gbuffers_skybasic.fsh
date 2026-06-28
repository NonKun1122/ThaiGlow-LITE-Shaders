#version 120
uniform int worldTime;
varying vec4 col;
varying vec3 dir;

#ifndef NIGHT_BRIGHTNESS
#define NIGHT_BRIGHTNESS 0.3
#endif

void main() {
    float tod = mod(float(worldTime), 24000.0) / 24000.0;
    float h   = clamp(normalize(dir).y, 0.0, 1.0);

    float dayFactor;
    if (tod < 0.45) dayFactor = 1.0;
    else if (tod < 0.55) dayFactor = 1.0 - smoothstep(0.45, 0.55, tod);
    else if (tod > 0.95) dayFactor = smoothstep(0.95, 1.0, tod);
    else dayFactor = 0.0;

    vec3 zenith, horizon;

    if (tod < 0.1) {
        // Sunrise
        float t = smoothstep(0.0, 0.1, tod);
        zenith  = mix(vec3(0.08, 0.06, 0.15), vec3(0.30, 0.60, 1.00), t);
        horizon = mix(vec3(0.15, 0.08, 0.05), vec3(0.80, 1.00, 1.00), t);
    } else if (tod < 0.25) {
        // Morning
        zenith  = vec3(0.30, 0.60, 1.00);
        horizon = vec3(0.80, 1.00, 1.00);
    } else if (tod < 0.45) {
        // Day
        zenith  = vec3(0.30, 0.60, 1.00);
        horizon = vec3(0.80, 1.00, 1.00);
    } else if (tod < 0.55) {
        // Sunset - fade blue to dark blue
        float t = smoothstep(0.45, 0.55, tod);
        zenith  = mix(vec3(0.30, 0.60, 1.00), vec3(0.03, 0.03, 0.20), t);
        horizon = mix(vec3(0.80, 1.00, 1.00), vec3(0.02, 0.02, 0.10), t);
    } else if (tod < 0.75) {
        // Evening - fade to night dark blue
        float t = smoothstep(0.55, 0.75, tod);
        zenith  = mix(vec3(0.03, 0.03, 0.20), vec3(0.00, 0.00, 0.08), t);
        horizon = mix(vec3(0.02, 0.02, 0.10), vec3(0.00, 0.00, 0.02), t);
    } else {
        // Night - dark blue
        zenith  = vec3(0.00, 0.00, 0.08);
        horizon = vec3(0.00, 0.00, 0.02);
    }

    vec3 sky = mix(horizon, zenith, pow(h, 0.45));

    // Apply NIGHT_BRIGHTNESS
    sky = sky * mix(1.0, NIGHT_BRIGHTNESS, 1.0 - dayFactor);

    // Stars
    float starLuma = dot(col.rgb, vec3(0.33));
    float starFactor = pow(clamp((starLuma - 0.2) * 1.5, 0.0, 1.0), 0.8) * (1.0 - dayFactor);

    gl_FragColor = vec4(clamp(sky + col.rgb * starFactor * 0.8, 0.0, 1.0), 1.0);
}
