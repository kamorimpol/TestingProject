Shader "Unlit/Water"
{
    Properties
    {
        _MainColor("Main Color", Color) = (0.5, 0.5, 1.0, 1.0)
        _DepthColor("Depth Color", Color) = (0.25, 0.25, 0.5, 1.0)
        _MaxDepth("Max Depth", Float) = 1


        _FoamNoiseTex("Noise", 2D) = "white" {}
        _FoamDepth("Foam Depth", Float) = 1
        _NoiseScale("_Noise Scale", Float) = 1
        _FoamNoiseScroll("Foam Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0)



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
                float4 screenPos : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _FoamNoiseTex;
            float4 _FoamNoiseTex_ST;

            float4 _MainColor;
            float4 _DepthColor;
            float _MaxDepth;
            float _NoiseScale;
            float _FoamDepth;
            float4 _FoamNoiseScroll;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _FoamNoiseTex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.screenPos.xy / i.screenPos.w;
                float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
                float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.screenPos.z);
                float depthDifference = backgroundDepth - surfaceDepth;
                float depthDifference01 = saturate(depthDifference / _MaxDepth);
                float4 color = lerp(_MainColor, _DepthColor, 1-depthDifference01);


                float foamDepthDifference01 = saturate(depthDifference / _FoamDepth);
                float2 animationOffset = float2(_FoamNoiseScroll.x * _Time.y, _FoamNoiseScroll.y * _Time.y);
                float2 noiseScale = _FoamNoiseScroll.xy * _NoiseScale;
                fixed4 noise = tex2D(_FoamNoiseTex, i.worldPos.xz / noiseScale + animationOffset);
                float surfaceNoise = noise > foamDepthDifference01 * 0.8 ? 1 : 0;
                // sample the texture
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return surfaceNoise + color;//1-depthDifference01;
            }
            ENDCG
        }
    }
}
