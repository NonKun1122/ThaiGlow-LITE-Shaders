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

    float rainDark = rainStrength * 0.4 + wetness * 0.2;

    // Apply brightness settings with proper night fog
    vec3 fogDayEarly = vec3(0.60, 1.00, 1.00) * DAY_BRIGHTNESS * (1.0 - rainDark);
    vec3 fogDayLate  = vec3(0.20, 0.40, 1.00) * DAY_BRIGHTNESS * (1.0 - rainDark);
    vec3 fogNight    = vec3(0.05, 0.05, 0.12) * NIGHT_BRIGHTNESS * (1.0 - rainDark);

    vec3 fogCol;
    if (tod < 0.25) {
        float t = smoothstep(0.0, 0.25, tod);
        fogCol = mix(vec3(0.40, 0.20, 0.08) * DAY_BRIGHTNESS, fogDayEarly, t);
    } else if (tod < 0.45) {
        fogCol = fogDayEarly;
    } else if (tod < 0.55) {
        float t = smoothstep(0.45, 0.55, tod);
        // ลดการผสมสีส้ม ค่อย ๆ เข้มไป
        vec3 sunsetCol = vec3(0.50, 0.25, 0.10) * (1.0 - t);
        fogCol = mix(fogDayEarly, fogNight, t) + sunsetCol;
    } else if (tod < 0.75) {
        float t = smoothstep(0.55, 0.75, tod);
        fogCol = mix(vec3(0.15, 0.10, 0.15), fogNight, t);
    } else {
        fogCol = fogNight;
    }

    if (depth < 1.0) {
        float fogStart  = 0.65;
        float fogFactor = clamp((linD - fogStart) * 2.5, 0.0, FOG_DENSITY);
        c = mix(c, fogCol, fogFactor);
    }
#endif

    float rainDarkness = rainStrength * 0.4 + wetness * 0.2;
    c *= 1.0 - rainDarkness;

    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
    c = mix(vec3(luma), c, 1.30);
    c = c * 1.10 - 0.01;
    c.r *= 1.01;
    c.g *= 1.005;

    gl_FragColor = vec4(clamp(c, 0.0, 1.0), 1.0);
}
