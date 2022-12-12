
fixed4 _LightColor0;


float lightFalloff(float distance) {
    return 1/(distance * distance);
}

float lambertLighting(float3 lightDirection, float3 normal) {
    return clamp(dot(lightDirection, normal),0,1);
}

float blinnPhong(float3 viewDirection, float3 lightDirection, float3 normal, float roughness) {
    float3 halfLightView = normalize(lightDirection + viewDirection);
    float  halfLightAngle = clamp(dot(halfLightView, normal),0,1);
    return pow(halfLightAngle, roughness);
}

float3 calculateLighting(float3 normal, float3 worldPos, float3 albedo, float roughness, float3 specularColor) {
    // Calculate Light Direction and Distance
    float3 lightDirection;
    float  lightDistance;
    float3 viewDirection = normalize(_WorldSpaceCameraPos - worldPos);

    if(_WorldSpaceLightPos0.w == 0.0) {
        // We have a directional Light
        lightDirection = _WorldSpaceLightPos0.xyz;
        lightDistance = 1;
    } else {
        // We have a point Light
        float3 lightPos = _WorldSpaceLightPos0.xyz;
        lightDirection = normalize(lightPos - worldPos);
        lightDistance  = distance (lightPos,  worldPos);
    }

    fixed3 incomingLight = _LightColor0 * lightFalloff(lightDistance);

    fixed3 diffuseLight  = lambertLighting(lightDirection, normal)           * albedo;
    fixed3 specularLight = blinnPhong(viewDirection, lightDirection, normal, roughness) * specularColor;
                
    fixed3 lightCol      = incomingLight * (diffuseLight + specularLight);

    lightCol += UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

    return lightCol;
}