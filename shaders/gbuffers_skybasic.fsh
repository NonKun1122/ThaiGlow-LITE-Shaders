#version 120
uniform int worldTime;
varying vec4 col;
varying vec3 dir;

#ifndef NIGHT_BRIGHTNESS
#define NIGHT_BRIGHTNESS 0.6
#endif

void main() {
    float tod = mod(float(worldTime), 24000.0) / 24000.0;
    float h   = clamp(normalize(dir).y, 0.0, 1.0);

    // Day = tod 0.0-0.50, Night = tod 0.50-1.0
    float dayFactor;
    if (tod < 0.45) dayFactor = 1.0;
    else if (tod < 0.55) dayFactor = 1.0 - smoothstep(0.45, 0.55, tod);
    else if (tod > 0.95) dayFactor = smoothstep(0.95, 1.0, tod);
    else dayFactor = 0.0;

    vec3 zenith, horizon;

    if (tod < 0.10) {
        // Sunrise: orange → cyan
        float t = smoothstep(0.0, 0.10, tod);
        zenith  = mix(vec3(0.20, 0.15, 0.40), vec3(0.20, 0.40, 1.00), t);
        horizon = mix(vec3(1.00, 0.55, 0.15), vec3(0.60, 1.00, 1.00), t);
    } else if (tod < 0.25) {
        // Morning
        float t = smoothstep(0.10, 0.25, tod);
        zenith  = mix(vec3(0.20, 0.40, 1.00), vec3(0.20, 0.40, 1.00), t);
        horizon = mix(vec3(0.60, 1.00, 1.00), vec3(0.60, 1.00, 1.00), t);
    } else if (tod < 0.45) {
        // DAY: #3366FF top → #99FFFF bottom
        zenith  = vec3(0.20, 0.40, 1.00);   // #3366FF
        horizon = vec3(0.60, 1.00, 1.00);   // #99FFFF
    } else if (tod < 0.55) {
        // Sunset
        float t = smoothstep(0.45, 0.55, tod);
        zenith  = mix(vec3(0.20, 0.40, 1.00), vec3(0.30, 0.15, 0.35), t);
        horizon = mix(vec3(0.60, 1.00, 1.00), vec3(1.00, 0.50, 0.15), t);
    } else if (tod < 0.75) {
        // Evening
        float t = smoothstep(0.55, 0.75, tod);
        zenith  = mix(vec3(0.30, 0.15, 0.35), vec3(0.00, 0.00, 0.40), t);
        horizon = mix(vec3(1.00, 0.50, 0.15), vec3(0.00, 0.00, 0.10), t);
    } else {
        // NIGHT: #000099 top → #000000 bottom
        zenith  = vec3(0.00, 0.00, 0.40);   // #000066 (near #000099)
        horizon = vec3(0.00, 0.00, 0.05);   // near #000000
    }

    // Mix: h=0 (bottom/horizon) → h=1 (top/zenith)
    vec3 sky = mix(horizon, zenith, pow(h, 0.45));

    // Apply night brightness
    sky *= mix(1.0, NIGHT_BRIGHTNESS, 1.0 - dayFactor);

    // Stars at night
    float starLuma = dot(col.rgb, vec3(0.333));
    float starFactor = clamp((starLuma - 0.35) * 2.5, 0.0, 1.2) * (1.0 - dayFactor);

    // Ensure we always output something visible
    sky = max(sky, vec3(0.02));

    gl_FragColor = vec4(sky + col.rgb * starFactor, 1.0);
}
