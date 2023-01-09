Shader "Unlit/Glass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _FresnelPower ("Fresnel Power", Float) = 1
        _Roughness ("Roughness", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend One One
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "ElectiveLighting.cginc"

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
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                // Move everything to world space
                o.normal = mul(UNITY_MATRIX_M, v.normal);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex);
                return o;
            }
            
            float4 _Color;
            float  _FresnelPower;
            float  _Roughness;

            fixed4 frag (v2f i) : SV_Target
            {
                i.normal = normalize(i.normal);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color;
                float3 viewDir = i.worldPos - _WorldSpaceCameraPos;
                viewDir = normalize(viewDir);
                float facing = dot(i.normal, viewDir) * -1;
                float inverseFacing = 1-facing;
                float fresnel = pow(inverseFacing, _FresnelPower);

                // BlinnPhong goes here
                float3 lighting = calculateLighting(i.normal, i.worldPos, float3(0,0,0), _Roughness, col);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col * fresnel + float4(lighting, 1);
            }
            ENDCG
        }
    }
}
