#version 120

#ifndef ENABLE_FOG
#define ENABLE_FOG 1
#endif
#ifndef FOG_DENSITY
#define FOG_DENSITY 0.5
#endif
#ifndef NIGHT_BRIGHTNESS
#define NIGHT_BRIGHTNESS 0.3
#endif
#ifndef DAY_BRIGHTNESS
#define DAY_BRIGHTNESS 1.0
#endif

uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform float near;
uniform float far;
uniform int worldTime;
uniform float rainStrength;
uniform float wetness;
varying vec2 uv;

float linearDepth(float d) {
    return (2.0 * near) / (far + near - d * (far - near));
}

void main() {
    vec3 c = texture2D(gcolor, uv).rgb;

#if ENABLE_FOG == 1
    float depth = texture2D(depthtex0, uv).r;
    float linD  = linearDepth(depth);

    float tod = mod(float(worldTime), 24000.0) / 24000.0;

    float dayFactor;
    if (tod < 0.45) dayFactor = 1.0;
    else if (tod < 0.55) dayFactor = 1.0 - smoothstep(0.45, 0.55, tod);
    else if (tod > 0.95) dayFactor = smoothstep(0.95, 1.0, tod);
    else dayFactor = 0.0;

    float rainDark = rainStrength * 0.3 + wetness * 0.15;

    vec3 fogDayEarly = vec3(0.65, 1.00, 1.00) * DAY_BRIGHTNESS * (1.0 - rainDark);
    vec3 fogDayLate  = vec3(0.40, 0.60, 1.00) * DAY_BRIGHTNESS * (1.0 - rainDark);
    vec3 fogNight    = vec3(0.01, 0.01, 0.05) * NIGHT_BRIGHTNESS;

    vec3 fogCol;
    if (tod < 0.25) {
        float t = smoothstep(0.0, 0.25, tod);
        fogCol = mix(vec3(0.2, 0.1, 0.05) * DAY_BRIGHTNESS, fogDayEarly, t);
    } else if (tod < 0.45) {
        fogCol = fogDayEarly;
    } else if (tod < 0.55) {
        float t = smoothstep(0.45, 0.55, tod);
        fogCol = mix(fogDayEarly, fogNight, t);
    } else if (tod < 0.75) {
        float t = smoothstep(0.55, 0.75, tod);
        fogCol = mix(fogNight, vec3(0.00, 0.00, 0.01), t);
    } else {
        fogCol = vec3(0.00, 0.00, 0.01);
    }

    if (depth < 1.0) {
        float fogStart  = 0.7;
        float fogFactor = clamp((linD - fogStart) * 2.0, 0.0, FOG_DENSITY);
        c = mix(c, fogCol, fogFactor);
    }
#endif

    float rainDarkness = rainStrength * 0.3 + wetness * 0.15;
    c *= 1.0 - rainDarkness * 0.2;

    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
    c = mix(vec3(luma), c, 1.2);
    c = c * 1.05;

    gl_FragColor = vec4(clamp(c, 0.0, 1.0), 1.0);
}
