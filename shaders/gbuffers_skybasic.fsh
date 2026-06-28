#version 120
uniform int worldTime;
varying vec4 col;
varying vec3 dir;

void main() {
    float tod = mod(float(worldTime), 24000.0) / 24000.0;
    float h   = clamp(normalize(dir).y, 0.0, 1.0);

    vec3 zenith, horizon;
    if (tod < 0.25) {
        float t = smoothstep(0.0, 0.25, tod);
        zenith  = mix(vec3(0.05, 0.06, 0.25), vec3(0.08, 0.38, 0.88), t);
        horizon = mix(vec3(0.55, 0.25, 0.10), vec3(0.55, 0.76, 1.00), t);
    } else if (tod < 0.62) {
        // กลางวัน: ฟ้าสด ไม่เทา
        zenith  = vec3(0.08, 0.38, 0.88);
        horizon = vec3(0.52, 0.74, 1.00);
    } else if (tod < 0.75) {
        float t = smoothstep(0.62, 0.75, tod);
        zenith  = mix(vec3(0.08, 0.38, 0.88), vec3(0.06, 0.05, 0.22), t);
        horizon = mix(vec3(0.52, 0.74, 1.00), vec3(0.92, 0.38, 0.12), t);
    } else {
        zenith  = vec3(0.04, 0.05, 0.20);
        horizon = vec3(0.05, 0.07, 0.15);
    }

    vec3 sky = mix(horizon, zenith, pow(h, 0.50));
    sky *= 0.95; // ลดความสว่างกลางวันลงนิดหน่อยให้บรรยากาศมืดขึ้น

    float starLuma   = dot(col.rgb, vec3(0.333));
    float starFactor = clamp((starLuma - 0.35) * 2.5, 0.0, 1.2);
    gl_FragColor = vec4(sky + col.rgb * starFactor, 1.0);
}
