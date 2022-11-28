Shader "Unlit/VertexColors"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _RedTex ("Red Texture", 2D) = "white" {}
        _GreenTex ("Green Texture", 2D) = "white" {}
        _BlueTex ("Blue Texture", 2D) = "white" {}
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
            // 5. add textures for green and blue channel [X]
            // 6. Show the MainTex wherever no other texture is showing [ ]
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
            sampler2D _RedTex;
            sampler2D _GreenTex;
            sampler2D _BlueTex;
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
                fixed4 baseTexture = tex2D(_MainTex, i.uv);
                baseTexture *= clamp(1-(i.vertexColor.r + i.vertexColor.g + i.vertexColor.b), 0, 1);

                // ============ RED TEXTURE ============
                fixed4 redTexture = tex2D(_RedTex, i.uv);
                redTexture *= i.vertexColor.r;
                // ============ GREEN TEXTURE ============
                fixed4 greenTexture = tex2D(_GreenTex, i.uv);
                greenTexture *= i.vertexColor.g;
                // ============ BLUE TEXTURE ============
                fixed4 blueTexture = tex2D(_BlueTex, i.uv);
                blueTexture *= i.vertexColor.b;


                return baseTexture + redTexture + greenTexture + blueTexture;
            }
            ENDCG
        }
    }
}
