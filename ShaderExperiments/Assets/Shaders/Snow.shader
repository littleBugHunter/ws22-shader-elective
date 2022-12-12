Shader "Unlit/Snow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Noise", 2D)  = "grey" {}
        _Roughness     ("Roughness", Float) = 10
        _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            float4    _MainTex_ST;
            sampler2D _NoiseTex;
            float     _Roughness;
            float4    _SpecularColor;
            float     _NoiseStrength;


            // this is already declared in "UnityCG.cginc"
            // float4 _WorldSpaceLightPos0;

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

            fixed4 frag (v2f i) : SV_Target
            {
                i.normal = normalize(i.normal);
                fixed4 albedo = tex2D(_MainTex, i.uv);
                float3 noise  = tex2D(_NoiseTex, i.uv);
                // noise is from 0 to 1 but we want it to go from -1 to 1
                noise *= 2;
                noise -= 1;

                i.normal += noise * _NoiseStrength;

                fixed3 lightCol      = calculateLighting(i.normal, i.worldPos, albedo, _Roughness, _SpecularColor);
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
