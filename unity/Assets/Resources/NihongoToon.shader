// Đổ bóng kiểu hoạt hình: 3 mức sáng + viền đen, giống bản phác thảo.
Shader "Nihongo/Toon"
{
    Properties
    {
        _Color ("Màu", Color) = (1, 1, 1, 1)
        _Emission ("Phát sáng", Color) = (0, 0, 0, 0)
        _Outline ("Độ dày viền", Float) = 0.025
        _OutlineColor ("Màu viền", Color) = (0.1, 0.08, 0.15, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass
        {
            Name "OUTLINE"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            float _Outline;
            fixed4 _OutlineColor;
            struct v2f { float4 pos : SV_POSITION; };
            v2f vert (appdata_base v)
            {
                v2f o;
                float3 n = normalize(v.normal);
                o.pos = UnityObjectToClipPos(v.vertex + float4(n * _Outline, 0));
                return o;
            }
            fixed4 frag (v2f i) : SV_Target { return _OutlineColor; }
            ENDCG
        }

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            fixed4 _Color;
            fixed4 _Emission;
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
                SHADOW_COORDS(1)
            };
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o)
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                float ndl = dot(normalize(i.normal), normalize(_WorldSpaceLightPos0.xyz));
                float lit = min(saturate(ndl), SHADOW_ATTENUATION(i));
                float band = lit > 0.55 ? 1.0 : (lit > 0.15 ? 0.72 : 0.5);
                float3 ambient = ShadeSH9(float4(normalize(i.normal), 1)) * 0.35;
                float3 c = _Color.rgb * (band * _LightColor0.rgb * 0.75 + ambient) + _Emission.rgb;
                return fixed4(c, 1);
            }
            ENDCG
        }

        // Bóng đổ lên vật khác.
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
    Fallback "Diffuse"
}
