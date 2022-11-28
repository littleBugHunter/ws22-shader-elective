Shader "Unlit/VertexColors"
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
            
            // 1. get the vertex colors [X]
            // 2. move them to the fragment shader [X]
            // 3. return vertex colors to the screen [X]
            // 4. mask the texture with the vertex color [X]
            // 5. add textures for green and blue channel [ ]
            // ???
            // Profit [ ]
            
            
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
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
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.vertexColor = v.vertexColor;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 redTexture = tex2D(_MainTex, i.uv);
                redTexture *= i.vertexColor.r;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, redTexture);
                return redTexture;
            }
            ENDCG
        }
    }
}
