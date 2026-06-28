#version 120
uniform sampler2D texture;
uniform int worldTime;

varying vec2 uv;
varying vec4 col;
varying vec3 norm;
varying vec3 vPos;
varying float bl;
varying float sl;

void main() {
    float tod     = mod(float(worldTime), 24000.0) / 24000.0;
    float night   = (tod > 0.75) ? smoothstep(0.75, 0.88, tod) :
                    (tod < 0.10) ? smoothstep(0.10, 0.00, tod) : 0.0;

    vec3  viewDir = normalize(-vPos);
    float fresnel = pow(1.0 - max(dot(normalize(norm), viewDir), 0.0), 4.0);

    vec3 skyCol   = mix(vec3(0.45, 0.68, 1.0), vec3(0.18, 0.28, 0.50), night);
    vec3 waterCol = mix(vec3(0.05, 0.16, 0.38), vec3(0.10, 0.28, 0.55), sl * sl);
    vec3 color    = mix(waterCol, skyCol, fresnel * 0.6);

    vec3 torchC = vec3(1.0, 0.65, 0.28) * (bl * bl * 2.0);
    color += torchC * 0.2;

    gl_FragColor = vec4(color, mix(0.60, 0.90, fresnel));
}
