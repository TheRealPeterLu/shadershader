Shader "Unlit/UnlitRim"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Tint("Tint", Color) = (0,0,0,0)
		_RimColor ("Rim Color", Color) = (0,0,0,0)
		_RimPower ("Rim Power", Range(0,5)) = 0
		_OutLineColor("Out Line Color", Color) = (0,0,0,1)
		_OutLineWidth("Out Line Width", Range(1,5)) = 1
		_NoiseSpeed ("Noise Speed", Float) = 0
		_NoiseDensity ("Noise Density", Float) = 0
		_NoiseStrength("Noise Strength", Range(0,0.1)) = 0
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			
			float _OutLineWidth;
			float _NoiseDensity;
			float _NoiseStrength;
			float _NoiseSpeed;
			float4 _Tint;
			float4 _OutLineColor;

			v2f vert (appdata v)
			{
				v2f o;
				v.vertex.xyz *= _OutLineWidth;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex.x += sin((_Time.y * _NoiseSpeed + o.vertex.y) * _NoiseDensity) * _NoiseStrength;
				o.vertex.y += sin((_Time.y * _NoiseSpeed + o.vertex.x) * _NoiseDensity) * _NoiseStrength;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OutLineColor;
			}
			ENDCG
		}

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
			float _NoiseDensity;
			float _NoiseStrength;
			float _NoiseSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				o.viewDir = ObjSpaceViewDir(v.vertex);
				o.vertex.x += sin((_Time.y * _NoiseSpeed/4 + o.vertex.y) * _NoiseDensity/2) * _NoiseStrength/4;
				o.vertex.y += sin((_Time.y * _NoiseSpeed/4 + o.vertex.x) * _NoiseDensity/2) * _NoiseStrength/4;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float dotProduct = 1 - saturate(dot(normalize(i.normal), normalize(i.viewDir)));
				dotProduct = pow(dotProduct, _RimPower);

				fixed4 col = tex2D(_MainTex, i.uv) * _Tint + dotProduct * _RimColor;

				return col;
			}
			ENDCG
		}
	}
}
