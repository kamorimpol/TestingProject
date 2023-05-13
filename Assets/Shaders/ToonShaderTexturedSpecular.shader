Shader "Custom/Toon1"
{
    Properties
    {
        _MainColor("Color", Color) = (0.8,0.8,0.8,1)

        [Toggle(USE_MAIN_TEXTURE)]
        _UseMainTexture("Use Main Texture", Float) = 0
        [NoScaleOffset] _MainTex("Texture", 2D) = "white" {}

        _Glossiness("Glossiness", Range(0.001, 0.999)) = 0.5

          

    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "LightMode" = "ForwardBase"
            "PassFlags" = "OnlyDirectional"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma shader_feature USE_MAIN_TEXTURE
            #pragma shader_feature USE_SPECULAR
            #pragma shader_feature USE_RIM
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

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
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                SHADOW_COORDS(2)
                float3 worldPos : TEXCOORD3;
                float3 viewDir : TEXCOORD4;
            };

            float4 _MainColor;
            sampler2D _MainTex;
            float4 _RimColor;
            float4 _ShadowColor;
            float _Glossiness;


            //float3 rgb2hsv(float3 c)
            //{
            //    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            //    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
            //    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

            //    float d = q.x - min(q.w, q.y);
            //    float e = 1.0e-10;
            //    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            //}


            //float3 shift_col(float3 RGB, float3 shift)
            //{
            //    float3 RESULT = float3(RGB);
            //    float VSU = shift.z * shift.y * cos(shift.x * 3.14159265 / 180);
            //    float VSW = shift.z * shift.y * sin(shift.x * 3.14159265 / 180);

            //    RESULT.x = (.299 * shift.z + .701 * VSU + .168 * VSW) * RGB.x
            //        + (.587 * shift.z - .587 * VSU + .330 * VSW) * RGB.y
            //        + (.114 * shift.z - .114 * VSU - .497 * VSW) * RGB.z;

            //    RESULT.y = (.299 * shift.z - .299 * VSU - .328 * VSW) * RGB.x
            //        + (.587 * shift.z + .413 * VSU + .035 * VSW) * RGB.y
            //        + (.114 * shift.z - .114 * VSU + .292 * VSW) * RGB.z;

            //    RESULT.z = (.299 * shift.z - .3 * VSU + 1.25 * VSW) * RGB.x
            //        + (.587 * shift.z - .588 * VSU - 1.05 * VSW) * RGB.y
            //        + (.114 * shift.z + .886 * VSU - .203 * VSW) * RGB.z;

            //    return (RESULT);
            //}



            half4 GetShadowColor(half4 color, float light)
            {
                return color * _ShadowColor;
            }


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                o.viewDir = WorldSpaceViewDir(v.vertex);
                TRANSFER_SHADOW(o)
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            

            fixed4 frag(v2f i) : SV_Target
            {

                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(i.viewDir);

                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float NdotH = dot(normal, halfVector);

                half4 diffuse = _MainColor;

                // Main Texture
                #if USE_MAIN_TEXTURE
                diffuse *= tex2D(_MainTex, i.uv);
                #endif


                //lighting
                float NdotL = dot(_WorldSpaceLightPos0, normal);
                float shadow = SHADOW_ATTENUATION(i);
                float lightIntensity = clamp(NdotL * shadow, 0, 1);
                diffuse = lerp(GetShadowColor(diffuse, lightIntensity), diffuse, lightIntensity);

                half4 reflection =  half4(0, 0, 0, 0);

                //Specular
                float specularIntensity = pow(NdotH, 1500.0 * _Glossiness);
                specularIntensity = clamp(specularIntensity, 0, 1);
                specularIntensity *= pow(_Glossiness, 0.5) * lightIntensity;
                reflection += specularIntensity;


                float4 rimDot = 1 - dot(viewDir, normal);
                rimDot = pow(rimDot, 10 * ((_Glossiness * 0.8)));
                rimDot *= _Glossiness;
                reflection += _RimColor * rimDot;

                half4 finalColor = diffuse * (1 - reflection);
                finalColor += reflection;

                UNITY_APPLY_FOG(i.fogCoord, finalColor);
                return finalColor;
            }
            ENDCG
        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
