#version 120

// Iris-compatible option declarations (OptiFine uses #define injection instead)
const int ENABLE_FOG = 1; // [0 1]

#ifndef ENABLE_FOG
#define ENABLE_FOG 1
#endif

uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform float near;
uniform float far;
uniform int worldTime;
varying vec2 uv;

float linearDepth(float d) {
    return (2.0 * near) / (far + near - d * (far - near));
}

void main() {
    vec3 c = texture2D(gcolor, uv).rgb;

#if ENABLE_FOG == 1
    float depth  = texture2D(depthtex0, uv).r;
    float linD   = linearDepth(depth);

    // หมอกเปลี่ยนสีตามเวลา
    float tod = mod(float(worldTime), 24000.0) / 24000.0;
    vec3 fogCol;
    if (tod < 0.25)       fogCol = mix(vec3(0.30,0.20,0.15), vec3(0.62,0.81,1.00),
                                       smoothstep(0.0, 0.25, tod));
    else if (tod < 0.62)  fogCol = vec3(0.62, 0.81, 1.00);
    else if (tod < 0.75)  fogCol = mix(vec3(0.62,0.81,1.00), vec3(0.55,0.30,0.15),
                                       smoothstep(0.62, 0.75, tod));
    else                  fogCol = vec3(0.04, 0.06, 0.13);

    // sky (depth == 1.0) ไม่ใส่หมอก
    // เริ่มหมอกที่ระยะ 50% ของ view distance เพื่อไม่ให้ใกล้เกินไปและลด lag
    if (depth < 1.0) {
        float fogFactor = clamp((linD - 0.50) * 3.5, 0.0, 0.80);
        c = mix(c, fogCol, fogFactor);
    }
#endif

    // Saturation + contrast
    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
    c = mix(vec3(luma), c, 1.20);
    c = c * 1.08 - 0.04;
    c.r *= 1.015;
    c.b *= 0.985;

    gl_FragColor = vec4(clamp(c, 0.0, 1.0), 1.0);
}
