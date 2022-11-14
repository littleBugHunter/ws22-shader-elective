Shader "Unlit/Fire"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
        _Speed ("Speed", Float) = 2.0
        _Amplitude ("Amplitude (Wobble Size)", Float) = 1.0
        _Frequency ("Frequency", Float) = 1.0
        _CenterShift ( "Center Shift", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        ZWrite Off
        Blend One One

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            float     _Speed;
            float     _Amplitude;
            float     _Frequency;
            float     _CenterShift;

            v2f vert (appdata v)
            {
                v2f o;
                float wobble = sin(v.vertex.y * _Frequency + _Time.y * _Speed) * _Amplitude;
                
                float strength = clamp( v.vertex.y+_CenterShift,0,1 );
                wobble *= strength;

                v.vertex.x += wobble;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 _Color;

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
