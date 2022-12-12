Shader "Unlit/SpecularLight"
{
    Properties
    {
        _MainTex       ("Texture", 2D) = "white" {}
        _Roughness     ("Roughness", Float) = 10
        _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        /*
        - Get our Variables
          - Light Direction [x]
          - Light Color     [x]
          - Normal          [x]
          - View Direction  [x]
        - Create Properties
          - Roughness/Glossiness [x]
          - Specular Color       [x]
        - Create BlinnPhong Function
          - Get the halfDir (normalized sum of lightDir and viewDir)
          - Get the angle between halfDir and Normal
          - inverse that angle
          - take it to the power of Roughness
          - multiply everything together
        */

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL; 
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            float     _Roughness;
            float4    _SpecularColor;


            // this is already declared in "UnityCG.cginc"
            // float4 _WorldSpaceLightPos0;
            fixed4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                float4 objectSpacePos = v.vertex;
                o.worldPos = mul(UNITY_MATRIX_M, objectSpacePos);
                return o;
            }

            float lightFalloff(float distance) {
                return 1/(distance * distance);
            }

            float lambertLighting(float3 lightDirection, float3 normal) {
                return clamp(dot(lightDirection, normal),0,1);
            }

            float blinnPhong(float3 viewDirection, float3 lightDirection, float3 normal) {
                float3 halfLightView = normalize(lightDirection + viewDirection);
                float  halfLightAngle = clamp(dot(halfLightView, normal),0,1);
                return pow(halfLightAngle, _Roughness);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.normal = normalize(i.normal);
                // Calculate Light Direction and Distance
                float3 lightDirection;
                float  lightDistance;
                float3 viewDirection = normalize(_WorldSpaceCameraPos - i.worldPos);

                if(_WorldSpaceLightPos0.w == 0.0) {
                    // We have a directional Light
                    lightDirection = _WorldSpaceLightPos0.xyz;
                    lightDistance = 1;
                } else {
                    // We have a point Light
                    float3 lightPos = _WorldSpaceLightPos0.xyz;
                    float3 worldPos = i.worldPos;
                    lightDirection = normalize(lightPos - worldPos);
                    lightDistance  = distance (lightPos,  worldPos);
                }

                fixed4 albedo = tex2D(_MainTex, i.uv);

                fixed3 incomingLight = _LightColor0 * lightFalloff(lightDistance);

                fixed3 diffuseLight  = lambertLighting(lightDirection, i.normal)           * albedo;
                fixed3 specularLight = blinnPhong(viewDirection, lightDirection, i.normal) * _SpecularColor;
                
                fixed3 lightCol      = incomingLight * (diffuseLight + specularLight);

                fixed4 col = fixed4(0,0,0,1);
                col.rgb += lightCol;
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }

            ENDCG
        }
    }
}
