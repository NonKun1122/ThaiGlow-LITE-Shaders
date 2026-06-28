#version 120
uniform sampler2D texture;
uniform int worldTime;
varying vec2 uv;
varying vec4 col;
varying float bl;

void main() {
    vec4 albedo = texture2D(texture, uv) * col;
    if (albedo.a < 0.1) discard;

    // คำนวณเวลากลางวัน/กลางคืน
    float tod   = mod(float(worldTime), 24000.0) / 24000.0;
    float night = (tod > 0.75) ? smoothstep(0.75, 0.88, tod) :
                  (tod < 0.10) ? smoothstep(0.10, 0.00, tod) : 0.0;

    // แสงไฟในมือ: สว่างตอนกลางคืน, จางลงกลางวัน แต่ยังพอเห็น
    float torchMul = mix(0.55, 3.8, night);
    vec3 torch = vec3(1.0, 0.65, 0.28) * (bl * bl * torchMul);
    // base brightness + night floor เล็กน้อย
    vec3 base  = vec3(mix(0.85, 0.60, night));
    vec3 color = albedo.rgb * (base + torch);

    gl_FragColor = vec4(color, albedo.a);
}
