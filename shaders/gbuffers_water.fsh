#version 120

uniform sampler2D texture;
uniform sampler2D shadowtex0;
uniform int worldTime;
uniform float rainStrength;
uniform float wetness;

varying vec2 uv;
varying vec4 col;
varying vec3 norm;
varying float bl;
varying float sl;
varying vec4 shadowPos;

#ifndef DAY_BRIGHTNESS
#define DAY_BRIGHTNESS 0.85
#endif
#ifndef NIGHT_BRIGHTNESS
#define NIGHT_BRIGHTNESS 0.6
#endif
#ifndef TORCH_COLOR_R
#define TORCH_COLOR_R 1.0
#endif
#ifndef TORCH_COLOR_G
#define TORCH_COLOR_G 0.5
#endif
#ifndef TORCH_COLOR_B
#define TORCH_COLOR_B 0.1
#endif
#ifndef TORCH_STRENGTH
#define TORCH_STRENGTH 2.5
#endif
#ifndef ENABLE_SPECULAR
#define ENABLE_SPECULAR 1
#endif
#ifndef SHADOW_QUALITY
#define SHADOW_QUALITY 1
#endif

float getShadow(vec3 sp) {
    if (sp.x < 0.0 || sp.x > 1.0 || sp.y < 0.0 || sp.y > 1.0) return 1.0;

#if SHADOW_QUALITY == 0
    return step(sp.z - 0.001, texture2D(shadowtex0, sp.xy).r);
#elif SHADOW_QUALITY == 2
    float shadow = 0.0;
    float texel = 1.0 / 1024.0;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            shadow += step(sp.z - 0.001, texture2D(shadowtex0, sp.xy + vec2(float(x), float(y)) * texel).r);
        }
    }
    return shadow / 9.0;
#else
    float shadow = 0.0;
    float texel = 1.0 / 1024.0;
    for (int x = -1; x <= 1; x += 2) {
        for (int y = -1; y <= 1; y += 2) {
            shadow += step(sp.z - 0.001, texture2D(shadowtex0, sp.xy + vec2(float(x), float(y)) * texel).r);
        }
    }
    return shadow * 0.25;
#endif
}

void main() {
    vec4 albedo = texture2D(texture, uv) * col;
    if (albedo.a < 0.1) discard;

    float tod = mod(float(worldTime), 24000.0) / 24000.0;

    float dayFactor;
    if (tod < 0.45) dayFactor = 1.0;
    else if (tod < 0.55) dayFactor = 1.0 - smoothstep(0.45, 0.55, tod);
    else if (tod > 0.95) dayFactor = smoothstep(0.95, 1.0, tod);
    else dayFactor = 0.0;
    float nightFactor = 1.0 - dayFactor;

    float sl2 = sl * sl;
    float bl2 = bl * bl;
    float rainDarkness = rainStrength * 0.4 + wetness * 0.2;

    vec3 skyAmbDay   = vec3(0.50, 0.70, 1.00) * sl2 * 0.50 * DAY_BRIGHTNESS * (1.0 - rainDarkness);
    vec3 skyAmbNight = vec3(0.05, 0.05, 0.20) * sl2 * 0.35 * NIGHT_BRIGHTNESS;
    vec3 skyAmb = mix(skyAmbNight, skyAmbDay, dayFactor);

    vec3 torchColor = vec3(TORCH_COLOR_R, TORCH_COLOR_G, TORCH_COLOR_B);
    vec3 torchC = torchColor * (bl2 * mix(0.60, TORCH_STRENGTH * 0.5, nightFactor));

    vec3 nightFloor = vec3(0.06, 0.06, 0.15) * nightFactor * NIGHT_BRIGHTNESS;
    vec3 ambient = albedo.rgb * (skyAmb + torchC + vec3(0.04)) + albedo.rgb * nightFloor;

    vec3 waterTint = mix(vec3(0.12, 0.40, 0.75), vec3(0.06, 0.20, 0.45), nightFactor);
    ambient = mix(ambient, ambient * waterTint * 1.8, 0.40);

    vec3 sunCol;
    if (tod < 0.10)       sunCol = mix(vec3(1.00, 0.50, 0.15), vec3(1.00, 0.85, 0.50), tod / 0.10);
    else if (tod < 0.25)  sunCol = mix(vec3(1.00, 0.85, 0.50), vec3(1.00, 0.98, 0.90), (tod - 0.10) / 0.15);
    else if (tod < 0.45)  sunCol = vec3(1.00, 0.97, 0.85);
    else if (tod < 0.55)  sunCol = mix(vec3(1.00, 0.97, 0.85), vec3(1.00, 0.55, 0.20), (tod - 0.45) / 0.10);
    else if (tod < 0.75)  sunCol = mix(vec3(1.00, 0.55, 0.20), vec3(0.12, 0.15, 0.35), (tod - 0.55) / 0.20);
    else                  sunCol = vec3(0.12, 0.15, 0.35);

    float shadow = 1.0;
    if (dayFactor > 0.01) {
        shadow = getShadow(shadowPos.xyz);
    }

    float spec = 0.0;
    float fresnel = 0.0;
#if ENABLE_SPECULAR == 1
    vec3 viewDir  = normalize(-vec3(gl_ModelViewMatrix[3]));
    vec3 lightDir = normalize(vec3(0.55, 1.0, 0.4));
    vec3 halfDir  = normalize(lightDir + viewDir);
    spec    = pow(max(dot(norm, halfDir), 0.0), 24.0) * 0.8;
    fresnel = pow(1.0 - abs(dot(viewDir, norm)), 3.0);
#endif

    vec3 color = ambient + spec * sunCol * dayFactor * shadow + vec3(fresnel * 0.15) * sunCol;
    color *= 1.0 - rainDarkness;

    gl_FragData[0] = vec4(color, albedo.a * 0.85);
    gl_FragData[1] = vec4(norm * 0.5 + 0.5, 1.0);
}
