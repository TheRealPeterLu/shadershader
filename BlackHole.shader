
Shader "Custom/BlackHole" 
{
	Properties
    {
		_Distortion ("Distortion", Range(-5,5)) = 0
		_Color ("Color", Color) = (1,1,1,1)
        _Rim("Rim", Range(0, 1)) = 0
        _DistortionDistance ("Distortion Distance", Range(0,1)) = 0
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
            float _DistortionDistance;
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
                float dotProduct = dot(i.viewDir, i.normal);

                i.GrabUV.xy = i.GrabUV.xy + _Distortion * (_DistortionDistance - dotProduct) * i.normal.zyx;
                
                fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.GrabUV));
                
                col.rgb = lerp(col.rgb, _Color.rgb, 1 - clamp(_Rim - pow(dotProduct, _DistortionDistance + 3),0,1));

                return col;
            }
            ENDCG
        }
    }
}
