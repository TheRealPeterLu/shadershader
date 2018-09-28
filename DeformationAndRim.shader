Shader "Custom/DeformationAndRim" {
	Properties {
		[Header(Rim and Color)]
		_Color ("Color", Color) = (1,1,1,1)
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_RimPower("Rim Power", Range(0,5)) = 1
		_RimIntensity("Rim Intensity", Range(1, 5)) = 1
		
		[Space(25)]
		[Header(Deformation)]
		_DeformationSpeed("Deformation Speed", Range(0, 10)) = 1
		_DeformationStrength("Deformation Strength", Range(0, 10)) = 0
		_DeformationPeriod("Deformation Period", Float) = 10
		_DeformationDirection("Deformation Direction", Vector) = (1,0,0,0)
		_DeformationMask ("Deformation Mask", 2D) = "white"{}

		[Space(25)]
		[Header(Advanced Options)]
		 _SecondColor("Second color?", Color) = (0,0,0,0)

	}
	SubShader {
		
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 200
		Cull Back

		CGPROGRAM
		#pragma surface surf NoLight vertex:vert alpha:fade
		#pragma target 3.0

		
		sampler2D _DeformationMask;

		struct Input 
		{
			float3 worldPos;
			float2 uv_MainTex;
			float2 uv_DeformationMask;
			half3 viewDir;
		};

		fixed4 _Color;
		fixed4 _RimColor;
		fixed4 _SecondColor;
		
		float _RimPower;
		float _DeformationStrength;
		float _DeformationPeriod;
		float _DeformationSpeed;
		float _RimIntensity;

		float4 _DeformationDirection;

 		half4 LightingNoLight(SurfaceOutput s, fixed3 lightDir, fixed atten) 
		{
        	 return half4(s.Albedo, s.Alpha);
     	}

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			float4 tex = tex2Dlod (_DeformationMask, float4(v.texcoord.xy,0,0));

			v.vertex.x += sin((_Time.y * _DeformationSpeed + v.vertex.yz) * _DeformationPeriod) * _DeformationDirection.x * _DeformationStrength * tex.r;
			v.vertex.y += sin((_Time.y * _DeformationSpeed + v.vertex.xz) * _DeformationPeriod) * _DeformationDirection.y * _DeformationStrength * tex.r;
			v.vertex.z += sin((_Time.y * _DeformationSpeed + v.vertex.xy) * _DeformationPeriod) * _DeformationDirection.z * _DeformationStrength * tex.r;
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			float4 tex = tex2D (_DeformationMask, IN.uv_DeformationMask);

			half dotProduct = 1 - saturate( dot(normalize(IN.viewDir), normalize(o.Normal)));
			o.Emission = pow(dotProduct, _RimPower) * _RimColor * _RimIntensity;
			
			o.Albedo = lerp(_Color, _SecondColor, tex.r);
			//o.Alpha = pow(dotProduct, _RimPower) + _Color.a;
			o.Alpha = lerp(pow(dotProduct, _RimPower) + _Color.a, _SecondColor.a, tex.r);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
