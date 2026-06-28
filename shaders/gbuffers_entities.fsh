#version 120

// Iris-compatible option declarations (OptiFine uses #define injection instead)
const int ENABLE_DIRLIGHT = 1; // [0 1]

#ifndef ENABLE_DIRLIGHT
#define ENABLE_DIRLIGHT 1
#endif

uniform sampler2D texture;
uniform int worldTime;
uniform float rainStrength;

varying vec2 uv;
varying vec4 col;
varying vec3 norm;
varying float bl;
varying float sl;

vec3 getSunColor(float tod) {
    if (tod < 0.10) return mix(vec3(0.20,0.28,0.55), vec3(0.95,0.55,0.20), tod/0.10);
    if (tod < 0.25) return mix(vec3(0.95,0.55,0.20), vec3(0.90,0.85,0.70), (tod-0.10)/0.15);
    if (tod < 0.62) return vec3(0.88, 0.84, 0.72);
    if (tod < 0.75) return mix(vec3(0.88,0.84,0.72), vec3(0.95,0.48,0.12), (tod-0.62)/0.13);
    return vec3(0.06, 0.10, 0.22);
}

void main() {
    vec4 albedo = texture2D(texture, uv) * col;
    if (albedo.a < 0.1) discard;

    float tod   = mod(float(worldTime), 24000.0) / 24000.0;
    float night = (tod > 0.75) ? smoothstep(0.75, 0.88, tod) :
                  (tod < 0.10) ? smoothstep(0.10, 0.00, tod) : 0.0;

    float sl2 = sl * sl;
    float bl2 = bl * bl;

    // ambient skylight (กลางวันลดลงเล็กน้อยให้บรรยากาศมืดขึ้น)
    vec3 skyAmb  = mix(vec3(0.32,0.50,0.82), vec3(0.18,0.25,0.44), night) * sl2 * 0.38;
    // แสงไฟ (torch/โคมไฟ/บล็อกเรืองแสง): สว่างกว่าตอนกลางคืน, จางลงกลางวัน แต่ยังพอเห็นอยู่
    float torchMul = mix(0.55, 3.8, night);
    vec3 torchC  = vec3(1.0, 0.62, 0.25) * (bl2 * torchMul);
    // night floor: กลางคืนสว่างขึ้น ไม่มืดสนิท (เพิ่มจาก 0.03→0.10)
    vec3 nightFloor = vec3(0.10, 0.12, 0.18) * night;
    vec3 ambient = albedo.rgb * (skyAmb + torchC + vec3(0.06)) + albedo.rgb * nightFloor;

    vec3 sunCol  = getSunColor(tod);

#if ENABLE_DIRLIGHT == 1
    float dirLight = max(dot(norm, normalize(vec3(0.55, 1.0, 0.4))), 0.0);
    dirLight = dirLight * 0.5 + 0.5;
    // ลด diffuse กลางวันลง (0.80 → 0.60) ให้บรรยากาศไม่สว่างจนเกินไป
    vec3 diffuse = albedo.rgb * sunCol * dirLight * (1.0 - night * 0.90) * 0.60;
#else
    // แสงแบน (flat shading)
    vec3 diffuse = albedo.rgb * sunCol * 0.52 * (1.0 - night * 0.90);
#endif

    vec3 color = ambient + diffuse;

    if (rainStrength > 0.01) {
        float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
        color = mix(color, vec3(luma * 0.75), rainStrength * 0.5);
    }

    gl_FragColor = vec4(color, albedo.a);
}
