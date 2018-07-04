
Shader "Custom/GrabPass_HeatWave" 
{
	Properties
    {
		_Distortion ("Distortion", Range(-1,1)) = 0
		_Color ("Color", Color) = (1,1,1,1)
        _EdgeVisibility("EdgeVisibility", Range(0, 1)) = 0
        _Hollowness ("Hollowness", Range(0,1)) = 0
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
            float _EdgeVisibility;
            float _Hollowness;
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
                //float4 objectOrigin : TEXCOORD4;
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
               // o.objectOrigin = mul(unity_ObjectToWorld, float4(0.0,0.0,0.0,1.0) );
                return o;
            }
               
     
            fixed4 frag (v2f i) : COLOR
            {
                float dotProduct = dot(i.viewDir, i.normal);

                // if(dotProduct < 0.5)
                // {
                    i.GrabUV.xy = i.GrabUV.xy + _Distortion * (_Hollowness - dotProduct) * i.normal.zyx;
                //}
                
                fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.GrabUV));
                
                col.rgb = lerp(col.rgb, _Color.rgb, clamp(_EdgeVisibility - dotProduct,0,1));
                
                return col;
            }
            ENDCG
        }
    }
}
