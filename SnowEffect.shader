// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/SnowEffect" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_SnowColor("Snow Color", Color) = (0,0,0,0)
		_SnowAlpha("Snow Alpha", Range(0,1)) = 1
		_SnowLevel ("Snow Level", Range(0, 1)) = 1
		_SnowDir ("Snow Direction", Vector) = (0,1,0)
		_SnowDepth("Snow Depth", Range(0,10)) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_SnowNoise;
			float3 worldNormal;
			INTERNAL_DATA
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		half4 _SnowDir;
		half4 _SnowColor;
		float _SnowDepth;
		half _SnowLevel;
		half _SnowAlpha;

		sampler2D _SnowNoise;
		
		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void vert(inout appdata_full v) {
			float4 sn = mul(unity_WorldToObject, _SnowDir);
			if (dot(v.normal, normalize(sn.xyz)) >= _SnowLevel)
			{
				v.vertex.xyz += v.normal * _SnowDepth * _SnowLevel;
			}

		}

		void surf(Input IN, inout SurfaceOutputStandard o) {
			half4 c = tex2D(_MainTex, IN.uv_MainTex);

			float dotProduct = dot(WorldNormalVector(IN, o.Normal), _SnowDir.xyz);

			if (dotProduct >= _SnowLevel)
				o.Albedo = lerp(_SnowColor, c.rgb * _Color, (1-_SnowAlpha));
			else
				o.Albedo = lerp(c.rgb * _Color, _SnowColor, (dotProduct) - _SnowLevel);
			
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
