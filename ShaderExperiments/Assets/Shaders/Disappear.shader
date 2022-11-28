Shader "Unlit/Disappear"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            float rand(float3 myVector)  {
                return frac(sin( dot(myVector ,float3(12.9898,78.233,45.5432) )) * 43758.5453);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 worldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.worldPos = worldPos;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float3 _HitPos;
            float _HitTime;

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                if(_HitTime > 0.0) {
                    // if we are close to our hit pos
                    float distanceToHole = distance(_HitPos, i.worldPos);
                    float holeSize = _Time.y-_HitTime;
                    holeSize -= col.r*4;

                    float burnEdge = smoothstep(holeSize+0.4, holeSize+0.1, distanceToHole);
                    float charEdge = smoothstep(holeSize+0.05, holeSize+0.1, distanceToHole);

                    float holeAlpha = smoothstep(holeSize-0.1,holeSize,distanceToHole);

                    col.rgb += float3(1.0,0.3,0.02) * 5 * clamp(burnEdge,0,1);
                    col.rgb *= clamp(charEdge,0,1);
                    col.a *= clamp(holeAlpha,0,1);
                }

                float random = rand(i.worldPos + frac(_Time));
                if(random >= col.a) {
                    discard;
                }
                
                return col;
            }
            ENDCG
        }
    }
}
