
Shader "Custom/GrabPass" 
{
	Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_NormalMap ("Normal", 2D) = "white"{}
		_Distortion ("Distortion", Range(-1,1)) = 0
		_Color ("Color", Color) = (1,1,1,1)
    }
	SubShader 
	{
 
        Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
     
        GrabPass {"_GrabTexture"}
     
         
        Pass {
            Name "GrabOffset"
            Cull Back
            ZWrite Off
        	Blend Off
               
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
     
            #include "UnityCG.cginc"
     
            sampler2D _GrabTexture;
               
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
               
            float _Distortion;
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
                float3 normal : NORMAL;
            };
     
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.texcoord = v.texcoord;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.GrabUV = ComputeGrabScreenPos(o.pos);
                   
                return o;
            }
               
     
            fixed4 frag (v2f i) : COLOR
            {
                half4 bump = tex2D(_NormalMap, i.texcoord);
                half2 distortion = UnpackNormal(bump).rg;

                bump = normalize(bump);

                i.GrabUV.xy += distortion * _Distortion;
                
                fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.GrabUV));
                 
                return col * _Color;
                   
            }
            ENDCG
        }
    }
}
