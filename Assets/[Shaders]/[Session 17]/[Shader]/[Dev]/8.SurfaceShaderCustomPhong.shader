﻿Shader "ShaderSuperb/Session17/Dev/8.SurfaceShaderCustomPhong" 
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
		_Shininess ("Shininess", Range (1, 1000)) = 100
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf PhongX fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0



		sampler2D _MainTex;
		float _Shininess;
		fixed4 _Color;

		inline fixed4 LightingPhongX (SurfaceOutput s, half3 viewDir, UnityGI gi)
		{
			//P.S. all the directions passed into the lighting function are already in World Space
			UnityLight light = gi.light;
			float nl = max(0.0f, dot(s.Normal, light.dir));
			float3 diffuseTerm = nl * s.Albedo.rgb * light.color;
			float3 reflectionDirection = reflect(-light.dir, s.Normal);
			float3 specularDot = max(0.0, dot(viewDir, reflectionDirection)); //no more ambient
			float3 specular = pow(specularDot, _Shininess);
			float3 specularTerm = specular * _SpecColor.rgb * light.color.rgb;
			float3 finalColor = diffuseTerm.rgb + specularTerm;
			fixed4 c;
			c.rgb = finalColor;
			c.a = s.Alpha;
			#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
			c.rgb += s.Albedo * gi.indirect.diffuse;
			#endif
			return c;
		}

		inline void LightingPhongX_GI (SurfaceOutput s, UnityGIInput data, inout UnityGI gi)
		{
			gi = UnityGlobalIllumination (data, 1.0, s.Normal);
		}

		struct Input 
		{
			float2 uv_MainTex;
		};

		

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutput o) 
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
