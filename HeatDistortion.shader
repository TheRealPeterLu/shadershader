// Upgrade NOTE: replaced 'texRECT' with 'tex2D'

Shader "Custom/DistortionHeatWave" 
{
	Properties
    {
		_Distortion ("Distortion", Range(-5,5)) = 0
        _DistortionCenter ("Center Distortion", Range(-5,5)) = 0
		_Color ("Color", Color) = (1,1,1,1)
        _Rim("Rim", Range(0, 1)) = 0
        _Hollowness("Hollowness", Range(0,1)) = 0
    }
	SubShader 
	{
 
        Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
     
        GrabPass {"_GrabTexture"}
     
         
        Pass {
            Name "GrabDistort"
            Cull Back
            ZWrite Off
        	Blend Off
               
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
     
            #include "UnityCG.cginc"
     
            sampler2D _GrabTexture;
            float _Distortion;
            float _Rim;
            float _Hollowness;
            float _DistortionCenter;
            fixed4 _Color;

			struct appdata {
				float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
			};
               
     
            struct v2f {
                float4 pos : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 GrabUV : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float4 worldPos : TEXCOORD3;
                float3 normal : NORMAL;
                float2 distortionMapUV : TEXCOORD4;
            };
     
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.texcoord = v.texcoord;
                o.GrabUV = ComputeGrabScreenPos(o.pos);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
                return o;
            }
               
     
            fixed4 frag (v2f i) : COLOR
            {
               
                float dotProduct = saturate (dot(normalize(i.viewDir), normalize(i.normal)));
                
                if(dotProduct < _Hollowness)
                {
                    if(dotProduct > 0.2)
                    {
                        i.GrabUV.xy = i.GrabUV.xy + tan(dotProduct * 3.14 - _Hollowness) * _Distortion;
                    }
                }
                else
                {
                    i.GrabUV.xy = i.GrabUV.xy + sin((1 - dotProduct) * 3.14 * 2) * _DistortionCenter;
                }

                //i.GrabUV.xy = i.GrabUV.xy + _Distortion * (dotProduct - _Hollowness) * i.normal.zyx * (1 - dotProduct);
                
                fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.GrabUV));
                
                col.rgb = lerp(col.rgb, _Color.rgb, clamp(_Rim - dotProduct,0,1));

                return col;
            }
            ENDCG
        }
    }
}
