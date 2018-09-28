Shader "Unlit/OutterRim"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Tint("Tint", Color) = (0,0,0,0)
		_RimColor ("Rim Color", Color) = (0,0,0,0)
		_RimPower ("Rim Power", Range(0,5)) = 0
		_RimRadius ("Rim Radius", Range(0,1)) = 0
		// _OutLineColor("Out Line Color", Color) = (0,0,0,1)
		// _OutLineWidth("Out Line Width", Range(1,5)) = 1
		// _NoiseSpeed ("Noise Speed", Float) = 0
		// _NoiseDensity ("Noise Density", Float) = 0
		// _NoiseStrength("Noise Strength", Range(0,0.1)) = 0
	}

	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		LOD 100

		Blend One One

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
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
				float4 vertex : SV_POSITION;
				float3 viewDir : TEXCOORD1;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _RimColor;
			float4 _Tint;
			float _RimPower;
			float _RimRadius;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				o.viewDir = ObjSpaceViewDir(v.vertex);

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;

				float dotProduct = saturate(dot(normalize(i.normal), normalize(i.viewDir)));
				
				if(dotProduct > _RimRadius)
				{
					dotProduct = 0;
					col = _Tint;
				}
				else
				{
					dotProduct = 1 - dotProduct;
					dotProduct = pow(1 - dotProduct, _RimPower);
					col.a = dotProduct;
					col.rgb = dotProduct * _RimColor;
				}
				
				return col;
			}
			ENDCG
		}
	}
}
