#version 120

uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 uv;
varying vec4 col;
varying vec3 norm;
varying float bl;
varying float sl;
varying vec4 shadowPos;

#ifndef ENABLE_WATER_WAVE
#define ENABLE_WATER_WAVE 1
#endif

void main() {
    vec4 position = gl_Vertex;
    vec3 newNorm = vec3(0.0, 1.0, 0.0);

#if ENABLE_WATER_WAVE == 1
    float worldX = position.x + cameraPosition.x;
    float worldZ = position.z + cameraPosition.z;
    float wave = sin(frameTimeCounter * 1.5 + worldX * 0.8) * cos(frameTimeCounter * 1.2 + worldZ * 0.6);
    wave += sin(frameTimeCounter * 2.0 + worldX * 1.2) * 0.3;
    position.y += wave * 0.08;
    newNorm = normalize(vec3(-wave * 0.1, 1.0, -wave * 0.05));
#endif

    gl_Position = gl_ModelViewProjectionMatrix * position;

    vec4 eyePos = gl_ModelViewMatrix * position;
    shadowPos = shadowProjection * shadowModelView * eyePos;
    shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5;

    uv   = gl_MultiTexCoord0.st;
    col  = gl_Color;
    norm = gl_NormalMatrix * newNorm;

    vec2 lm = gl_MultiTexCoord1.st / 256.0;
    bl = lm.x;
    sl = lm.y;
}
