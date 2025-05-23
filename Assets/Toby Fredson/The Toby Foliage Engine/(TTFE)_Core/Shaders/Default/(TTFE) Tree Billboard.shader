// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toby Fredson/The Toby Foliage Engine/(TTFE) Tree Billboard"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(__________(TTFE) TREE BILLBOARD SHADER___________)][Header(_____________________________________________________)][Header(Texture Maps)][NoScaleOffset]_AlbedoMap("Albedo Map", 2D) = "white" {}
		[NoScaleOffset][Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		[NoScaleOffset]_MaskMapRGBA("Mask Map *RGB(A)", 2D) = "white" {}
		[NoScaleOffset]_NoiseMapGrayscale("Noise Map (Grayscale)", 2D) = "white" {}
		[Header(_____________________________________________________)][Header(Texture settings)][Header((Albedo))]_AlebedoColor("Alebedo Color", Color) = (1,1,1,0)
		[Header((Normal))]_NormalIntenisty("Normal Intenisty", Float) = 1
		[Header((Smoothness))]_SmoothnessIntensity("Smoothness Intensity", Range( 0 , 1)) = 1
		[Header((Ambient Occlusion))]_AmbientOcclusionIntensity("Ambient Occlusion Intensity", Range( 0 , 1)) = 1
		[Header((Translucency))]_TranslucencyPower("Translucency Power", Range( 1 , 10)) = 1
		[Header( _____________________________________________________)][Header(Shading Settings)][Header((Self Shading))]_VertexLighting("Vertex Lighting", Float) = 0
		_VertexShadow("Vertex Shadow", Float) = 0
		[Toggle(_SELFSHADING_ON)] _SelfShading("Self Shading", Float) = 0
		[Header(Seasons Settings)][Header((Season Control))]_ColorVariation("Color Variation", Range( 0 , 1)) = 1
		_DryLeafColor("Dry Leaf Color", Color) = (0.5568628,0.3730685,0.1764706,0)
		_DryLeavesScale("Dry Leaves - Scale", Float) = 0
		_DryLeavesOffset("Dry Leaves - Offset", Float) = 0
		_SeasonChangeGlobal("Season Change - Global", Range( -2 , 2)) = 0
		[Toggle]_BranchMaskR("Branch Mask *(R)", Float) = 1
		[Header(_____________________________________________________)][Header(Wind Settings)][Header((Global Wind Settings))]_GlobalWindStrength("Global Wind Strength", Range( 0 , 1)) = 1
		[KeywordEnum(GentleBreeze,WindOff)] _WindType("Wind Type", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Lit" }

		Cull Back
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 3.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120107


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _CLUSTERED_RENDERING

            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#pragma shader_feature_local _WINDTYPE_GENTLEBREEZE _WINDTYPE_WINDOFF
			#pragma shader_feature_local _SELFSHADING_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AlebedoColor;
			float4 _DryLeafColor;
			float _GlobalWindStrength;
			float _SeasonChangeGlobal;
			float _DryLeavesScale;
			float _DryLeavesOffset;
			float _ColorVariation;
			float _BranchMaskR;
			float _VertexLighting;
			float _VertexShadow;
			float _TranslucencyPower;
			float _NormalIntenisty;
			float _SmoothnessIntensity;
			float _AmbientOcclusionIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AlbedoMap;
			sampler2D _NoiseMapGrayscale;
			sampler2D _MaskMapRGBA;
			sampler2D _NormalMap;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult256_g1339 = (float3(0.0 , 0.0 , saturate( v.positionOS.xyz ).z));
				float3 break252_g1339 = v.positionOS.xyz;
				float3 appendResult255_g1339 = (float3(break252_g1339.x , ( break252_g1339.y * 0.15 ) , 0.0));
				float mulTime263_g1339 = _TimeParameters.x * 2.1;
				float3 temp_cast_0 = (v.positionOS.xyz.y).xxx;
				float2 appendResult300_g1339 = (float2(v.positionOS.xyz.x , v.positionOS.xyz.z));
				float3 temp_output_303_0_g1339 = ( cross( temp_cast_0 , float3( appendResult300_g1339 ,  0.0 ) ) * 0.005 );
				float3 appendResult270_g1339 = (float3(0.0 , v.positionOS.xyz.y , 0.0));
				float3 break269_g1339 = v.positionOS.xyz;
				float3 appendResult271_g1339 = (float3(break269_g1339.x , 0.0 , ( break269_g1339.z * 0.15 )));
				float mulTime282_g1339 = _TimeParameters.x * 2.3;
				float3 appendResult293_g1339 = (float3(v.positionOS.xyz.x , 0.0 , 0.0));
				float3 break288_g1339 = v.positionOS.xyz;
				float3 appendResult292_g1339 = (float3(0.0 , ( break288_g1339.y * 0.2 ) , ( break288_g1339.z * 0.4 )));
				float mulTime249_g1339 = _TimeParameters.x * 2.0;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float3 normalizeResult155_g1339 = normalize( ase_worldPos );
				float mulTime161_g1339 = _TimeParameters.x * 0.25;
				float simplePerlin2D159_g1339 = snoise( ( normalizeResult155_g1339 + mulTime161_g1339 ).xy*0.43 );
				float WindMask_LargeB169_g1339 = ( simplePerlin2D159_g1339 * 1.5 );
				float3 normalizeResult162_g1339 = normalize( ase_worldPos );
				float mulTime167_g1339 = _TimeParameters.x * 0.26;
				float simplePerlin2D166_g1339 = snoise( ( normalizeResult162_g1339 + mulTime167_g1339 ).xy*0.7 );
				float WindMask_LargeC170_g1339 = ( simplePerlin2D166_g1339 * 1.5 );
				float mulTime133_g1339 = _TimeParameters.x * 3.2;
				float3 worldToObj126_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_135_0_g1339 = ( mulTime133_g1339 + ( 0.02 * worldToObj126_g1339.x ) + ( worldToObj126_g1339.y * 0.14 ) + ( worldToObj126_g1339.z * 0.16 ) + float3(0.4,0.3,0.1) );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float mulTime111_g1339 = _TimeParameters.x * 2.3;
				float3 worldToObj103_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_106_0_g1339 = ( mulTime111_g1339 + ( 0.2 * worldToObj103_g1339 ) + float3(0.4,0.3,0.1) );
				float mulTime118_g1339 = _TimeParameters.x * 3.6;
				float3 temp_cast_4 = (v.positionOS.xyz.x).xxx;
				float3 worldToObj114_g1339 = mul( GetWorldToObjectMatrix(), float4( temp_cast_4, 1 ) ).xyz;
				float temp_output_119_0_g1339 = ( mulTime118_g1339 + ( 0.2 * worldToObj114_g1339.x ) );
				float3 temp_cast_5 = (0.0).xxx;
				#if defined(_WINDTYPE_GENTLEBREEZE)
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#elif defined(_WINDTYPE_WINDOFF)
				float3 staticSwitch312_g1339 = temp_cast_5;
				#else
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#endif
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_texcoord9 = v.positionOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( _GlobalWindStrength * staticSwitch312_g1339 );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif
				v.normalOS = v.normalOS;
				v.tangentOS = v.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( v.normalOS, v.tangentOS );

				o.tSpace0 = float4( normalInput.normalWS, vertexInput.positionWS.x );
				o.tSpace1 = float4( normalInput.tangentWS, vertexInput.positionWS.y );
				o.tSpace2 = float4( normalInput.bitangentWS, vertexInput.positionWS.z );

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord.xy;
					o.lightmapUVOrVertexSH.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( vertexInput.positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;
				o.clipPosV = vertexInput.positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.tangentOS = v.tangentOS;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionCS);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_AlbedoMap81_g1335 = IN.ase_texcoord8.xy;
				float2 uv_AlbedoMap83_g1335 = IN.ase_texcoord8.xy;
				float4 tex2DNode83_g1335 = tex2D( _AlbedoMap, uv_AlbedoMap83_g1335 );
				float2 uv_NoiseMapGrayscale98_g1335 = IN.ase_texcoord8.xy;
				float4 transform94_g1335 = mul(GetObjectToWorldMatrix(),float4( 1,1,1,1 ));
				float dotResult4_g1337 = dot( transform94_g1335.xy , float2( 12.9898,78.233 ) );
				float lerpResult10_g1337 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1337 ) * 43758.55 ) ));
				float3 normalizeResult120_g1335 = normalize( IN.ase_texcoord9.xyz );
				float DryLeafPositionMask124_g1335 = ( (distance( normalizeResult120_g1335 , float3( 0,0.8,0 ) )*1.0 + 0.0) * 1 );
				float4 lerpResult46_g1335 = lerp( ( _DryLeafColor * ( tex2DNode83_g1335.g * 2 ) ) , tex2DNode83_g1335 , saturate( (( ( tex2D( _NoiseMapGrayscale, uv_NoiseMapGrayscale98_g1335 ).r * lerpResult10_g1337 * DryLeafPositionMask124_g1335 ) - _SeasonChangeGlobal )*_DryLeavesScale + _DryLeavesOffset) ));
				float4 SeasonControl_Output88_g1335 = lerpResult46_g1335;
				Gradient gradient60_g1335 = NewGradient( 0, 2, 2, float4( 1, 0.276868, 0, 0 ), float4( 0, 1, 0.7818019, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float4 transform62_g1335 = mul(GetObjectToWorldMatrix(),float4( 1,1,1,1 ));
				float dotResult4_g1336 = dot( transform62_g1335.xy , float2( 12.9898,78.233 ) );
				float lerpResult10_g1336 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1336 ) * 43758.55 ) ));
				float4 lerpResult70_g1335 = lerp( SeasonControl_Output88_g1335 , ( ( SeasonControl_Output88_g1335 * 0.5 ) + ( SampleGradient( gradient60_g1335, lerpResult10_g1336 ) * SeasonControl_Output88_g1335 ) ) , _ColorVariation);
				float2 uv_MaskMapRGBA82_g1335 = IN.ase_texcoord8.xy;
				float4 lerpResult78_g1335 = lerp( tex2D( _AlbedoMap, uv_AlbedoMap81_g1335 ) , lerpResult70_g1335 , (( _BranchMaskR )?( tex2D( _MaskMapRGBA, uv_MaskMapRGBA82_g1335 ).r ):( 1.0 )));
				float3 temp_output_104_0_g1335 = ( ( IN.ase_texcoord9.xyz * float3( 2,1.3,2 ) ) / 25.0 );
				float dotResult107_g1335 = dot( temp_output_104_0_g1335 , temp_output_104_0_g1335 );
				float3 normalizeResult103_g1335 = normalize( IN.ase_texcoord9.xyz );
				float SelfShading115_g1335 = saturate( (( pow( abs( saturate( dotResult107_g1335 ) ) , 1.5 ) + ( ( 1.0 - (distance( normalizeResult103_g1335 , float3( 0,0.8,0 ) )*0.5 + 0.0) ) * 0.6 ) )*0.92 + -0.16) );
				#ifdef _SELFSHADING_ON
				float4 staticSwitch74_g1335 = ( lerpResult78_g1335 * (SelfShading115_g1335*_VertexLighting + _VertexShadow) );
				#else
				float4 staticSwitch74_g1335 = lerpResult78_g1335;
				#endif
				float4 LeafColorVariationSeasons_Output91_g1335 = staticSwitch74_g1335;
				float dotResult151_g1335 = dot( WorldViewDirection , -( _MainLightPosition.xyz + IN.ase_texcoord9.xyz ) );
				float2 uv_MaskMapRGBA152_g1335 = IN.ase_texcoord8.xy;
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float TobyTranslucency153_g1335 = ( saturate( dotResult151_g1335 ) * tex2D( _MaskMapRGBA, uv_MaskMapRGBA152_g1335 ).b * ase_lightColor.a );
				float TranslucencyIntensity39_g1335 = _TranslucencyPower;
				float4 Albedo_Output154_g1335 = ( ( _AlebedoColor * LeafColorVariationSeasons_Output91_g1335 ) * (1.0 + (TobyTranslucency153_g1335 - 0.0) * (TranslucencyIntensity39_g1335 - 1.0) / (1.0 - 0.0)) );
				
				float2 uv_NormalMap87_g1335 = IN.ase_texcoord8.xy;
				float3 unpack87_g1335 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap87_g1335 ), _NormalIntenisty );
				unpack87_g1335.z = lerp( 1, unpack87_g1335.z, saturate(_NormalIntenisty) );
				float3 Normal_Output155_g1335 = unpack87_g1335;
				
				float2 uv_MaskMapRGBA79_g1335 = IN.ase_texcoord8.xy;
				float4 tex2DNode79_g1335 = tex2D( _MaskMapRGBA, uv_MaskMapRGBA79_g1335 );
				float Smoothness_Output35_g1335 = ( tex2DNode79_g1335.a * _SmoothnessIntensity );
				
				float AoMapBase31_g1335 = tex2DNode79_g1335.g;
				float Ao_Output141_g1335 = ( pow( abs( AoMapBase31_g1335 ) , _AmbientOcclusionIntensity ) * ( 1.5 / ( ( saturate( TobyTranslucency153_g1335 ) * TranslucencyIntensity39_g1335 ) + 1.5 ) ) );
				
				float2 uv_AlbedoMap80_g1335 = IN.ase_texcoord8.xy;
				float Opacity_Output86_g1335 = ( 1.0 - tex2D( _AlbedoMap, uv_AlbedoMap80_g1335 ).a );
				

				float3 BaseColor = Albedo_Output154_g1335.rgb;
				float3 Normal = Normal_Output155_g1335;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = Smoothness_Output35_g1335;
				float Occlusion = Ao_Output141_g1335;
				float Alpha = 1;
				float AlphaClipThreshold = ( Opacity_Output86_g1335 * 1.4 );
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _CLEARCOAT
					float CoatMask = 0;
					float CoatSmoothness = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = ShadowCoords;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif
					inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
				#else
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
					#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				#ifdef _CLEARCOAT
					surfaceData.clearCoatMask       = saturate(CoatMask);
					surfaceData.clearCoatSmoothness = saturate(CoatSmoothness);
				#endif

				#ifdef _DBUFFER
					ApplyDecalToSurfaceData(IN.positionCS, surfaceData, inputData);
				#endif

				half4 color = UniversalFragmentPBR( inputData, surfaceData);

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += BaseColor * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += BaseColor * transmission;
						}
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += BaseColor * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += BaseColor * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120107


			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _WINDTYPE_GENTLEBREEZE _WINDTYPE_WINDOFF


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif				
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AlebedoColor;
			float4 _DryLeafColor;
			float _GlobalWindStrength;
			float _SeasonChangeGlobal;
			float _DryLeavesScale;
			float _DryLeavesOffset;
			float _ColorVariation;
			float _BranchMaskR;
			float _VertexLighting;
			float _VertexShadow;
			float _TranslucencyPower;
			float _NormalIntenisty;
			float _SmoothnessIntensity;
			float _AmbientOcclusionIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AlbedoMap;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 appendResult256_g1339 = (float3(0.0 , 0.0 , saturate( v.positionOS.xyz ).z));
				float3 break252_g1339 = v.positionOS.xyz;
				float3 appendResult255_g1339 = (float3(break252_g1339.x , ( break252_g1339.y * 0.15 ) , 0.0));
				float mulTime263_g1339 = _TimeParameters.x * 2.1;
				float3 temp_cast_0 = (v.positionOS.xyz.y).xxx;
				float2 appendResult300_g1339 = (float2(v.positionOS.xyz.x , v.positionOS.xyz.z));
				float3 temp_output_303_0_g1339 = ( cross( temp_cast_0 , float3( appendResult300_g1339 ,  0.0 ) ) * 0.005 );
				float3 appendResult270_g1339 = (float3(0.0 , v.positionOS.xyz.y , 0.0));
				float3 break269_g1339 = v.positionOS.xyz;
				float3 appendResult271_g1339 = (float3(break269_g1339.x , 0.0 , ( break269_g1339.z * 0.15 )));
				float mulTime282_g1339 = _TimeParameters.x * 2.3;
				float3 appendResult293_g1339 = (float3(v.positionOS.xyz.x , 0.0 , 0.0));
				float3 break288_g1339 = v.positionOS.xyz;
				float3 appendResult292_g1339 = (float3(0.0 , ( break288_g1339.y * 0.2 ) , ( break288_g1339.z * 0.4 )));
				float mulTime249_g1339 = _TimeParameters.x * 2.0;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float3 normalizeResult155_g1339 = normalize( ase_worldPos );
				float mulTime161_g1339 = _TimeParameters.x * 0.25;
				float simplePerlin2D159_g1339 = snoise( ( normalizeResult155_g1339 + mulTime161_g1339 ).xy*0.43 );
				float WindMask_LargeB169_g1339 = ( simplePerlin2D159_g1339 * 1.5 );
				float3 normalizeResult162_g1339 = normalize( ase_worldPos );
				float mulTime167_g1339 = _TimeParameters.x * 0.26;
				float simplePerlin2D166_g1339 = snoise( ( normalizeResult162_g1339 + mulTime167_g1339 ).xy*0.7 );
				float WindMask_LargeC170_g1339 = ( simplePerlin2D166_g1339 * 1.5 );
				float mulTime133_g1339 = _TimeParameters.x * 3.2;
				float3 worldToObj126_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_135_0_g1339 = ( mulTime133_g1339 + ( 0.02 * worldToObj126_g1339.x ) + ( worldToObj126_g1339.y * 0.14 ) + ( worldToObj126_g1339.z * 0.16 ) + float3(0.4,0.3,0.1) );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float mulTime111_g1339 = _TimeParameters.x * 2.3;
				float3 worldToObj103_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_106_0_g1339 = ( mulTime111_g1339 + ( 0.2 * worldToObj103_g1339 ) + float3(0.4,0.3,0.1) );
				float mulTime118_g1339 = _TimeParameters.x * 3.6;
				float3 temp_cast_4 = (v.positionOS.xyz.x).xxx;
				float3 worldToObj114_g1339 = mul( GetWorldToObjectMatrix(), float4( temp_cast_4, 1 ) ).xyz;
				float temp_output_119_0_g1339 = ( mulTime118_g1339 + ( 0.2 * worldToObj114_g1339.x ) );
				float3 temp_cast_5 = (0.0).xxx;
				#if defined(_WINDTYPE_GENTLEBREEZE)
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#elif defined(_WINDTYPE_WINDOFF)
				float3 staticSwitch312_g1339 = temp_cast_5;
				#else
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#endif
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( _GlobalWindStrength * staticSwitch312_g1339 );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir(v.normalOS);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#else
					positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_AlbedoMap80_g1335 = IN.ase_texcoord3.xy;
				float Opacity_Output86_g1335 = ( 1.0 - tex2D( _AlbedoMap, uv_AlbedoMap80_g1335 ).a );
				

				float Alpha = 1;
				float AlphaClipThreshold = ( Opacity_Output86_g1335 * 1.4 );
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

            #define _NORMAL_DROPOFF_TS 1
            #pragma multi_compile_instancing
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #define ASE_FOG 1
            #define _ALPHATEST_ON 1
            #define _NORMALMAP 1
            #define ASE_SRP_VERSION 120107


            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _WINDTYPE_GENTLEBREEZE _WINDTYPE_WINDOFF


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AlebedoColor;
			float4 _DryLeafColor;
			float _GlobalWindStrength;
			float _SeasonChangeGlobal;
			float _DryLeavesScale;
			float _DryLeavesOffset;
			float _ColorVariation;
			float _BranchMaskR;
			float _VertexLighting;
			float _VertexShadow;
			float _TranslucencyPower;
			float _NormalIntenisty;
			float _SmoothnessIntensity;
			float _AmbientOcclusionIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AlbedoMap;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult256_g1339 = (float3(0.0 , 0.0 , saturate( v.positionOS.xyz ).z));
				float3 break252_g1339 = v.positionOS.xyz;
				float3 appendResult255_g1339 = (float3(break252_g1339.x , ( break252_g1339.y * 0.15 ) , 0.0));
				float mulTime263_g1339 = _TimeParameters.x * 2.1;
				float3 temp_cast_0 = (v.positionOS.xyz.y).xxx;
				float2 appendResult300_g1339 = (float2(v.positionOS.xyz.x , v.positionOS.xyz.z));
				float3 temp_output_303_0_g1339 = ( cross( temp_cast_0 , float3( appendResult300_g1339 ,  0.0 ) ) * 0.005 );
				float3 appendResult270_g1339 = (float3(0.0 , v.positionOS.xyz.y , 0.0));
				float3 break269_g1339 = v.positionOS.xyz;
				float3 appendResult271_g1339 = (float3(break269_g1339.x , 0.0 , ( break269_g1339.z * 0.15 )));
				float mulTime282_g1339 = _TimeParameters.x * 2.3;
				float3 appendResult293_g1339 = (float3(v.positionOS.xyz.x , 0.0 , 0.0));
				float3 break288_g1339 = v.positionOS.xyz;
				float3 appendResult292_g1339 = (float3(0.0 , ( break288_g1339.y * 0.2 ) , ( break288_g1339.z * 0.4 )));
				float mulTime249_g1339 = _TimeParameters.x * 2.0;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float3 normalizeResult155_g1339 = normalize( ase_worldPos );
				float mulTime161_g1339 = _TimeParameters.x * 0.25;
				float simplePerlin2D159_g1339 = snoise( ( normalizeResult155_g1339 + mulTime161_g1339 ).xy*0.43 );
				float WindMask_LargeB169_g1339 = ( simplePerlin2D159_g1339 * 1.5 );
				float3 normalizeResult162_g1339 = normalize( ase_worldPos );
				float mulTime167_g1339 = _TimeParameters.x * 0.26;
				float simplePerlin2D166_g1339 = snoise( ( normalizeResult162_g1339 + mulTime167_g1339 ).xy*0.7 );
				float WindMask_LargeC170_g1339 = ( simplePerlin2D166_g1339 * 1.5 );
				float mulTime133_g1339 = _TimeParameters.x * 3.2;
				float3 worldToObj126_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_135_0_g1339 = ( mulTime133_g1339 + ( 0.02 * worldToObj126_g1339.x ) + ( worldToObj126_g1339.y * 0.14 ) + ( worldToObj126_g1339.z * 0.16 ) + float3(0.4,0.3,0.1) );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float mulTime111_g1339 = _TimeParameters.x * 2.3;
				float3 worldToObj103_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_106_0_g1339 = ( mulTime111_g1339 + ( 0.2 * worldToObj103_g1339 ) + float3(0.4,0.3,0.1) );
				float mulTime118_g1339 = _TimeParameters.x * 3.6;
				float3 temp_cast_4 = (v.positionOS.xyz.x).xxx;
				float3 worldToObj114_g1339 = mul( GetWorldToObjectMatrix(), float4( temp_cast_4, 1 ) ).xyz;
				float temp_output_119_0_g1339 = ( mulTime118_g1339 + ( 0.2 * worldToObj114_g1339.x ) );
				float3 temp_cast_5 = (0.0).xxx;
				#if defined(_WINDTYPE_GENTLEBREEZE)
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#elif defined(_WINDTYPE_WINDOFF)
				float3 staticSwitch312_g1339 = temp_cast_5;
				#else
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#endif
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( _GlobalWindStrength * staticSwitch312_g1339 );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = vertexInput.positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;
				o.clipPosV = vertexInput.positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_AlbedoMap80_g1335 = IN.ase_texcoord3.xy;
				float Opacity_Output86_g1335 = ( 1.0 - tex2D( _AlbedoMap, uv_AlbedoMap80_g1335 ).a );
				

				float Alpha = 1;
				float AlphaClipThreshold = ( Opacity_Output86_g1335 * 1.4 );

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120107


			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature EDITOR_VISUALIZATION

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _WINDTYPE_GENTLEBREEZE _WINDTYPE_WINDOFF
			#pragma shader_feature_local _SELFSHADING_ON


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef EDITOR_VISUALIZATION
					float4 VizUV : TEXCOORD2;
					float4 LightCoord : TEXCOORD3;
				#endif
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AlebedoColor;
			float4 _DryLeafColor;
			float _GlobalWindStrength;
			float _SeasonChangeGlobal;
			float _DryLeavesScale;
			float _DryLeavesOffset;
			float _ColorVariation;
			float _BranchMaskR;
			float _VertexLighting;
			float _VertexShadow;
			float _TranslucencyPower;
			float _NormalIntenisty;
			float _SmoothnessIntensity;
			float _AmbientOcclusionIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AlbedoMap;
			sampler2D _NoiseMapGrayscale;
			sampler2D _MaskMapRGBA;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult256_g1339 = (float3(0.0 , 0.0 , saturate( v.positionOS.xyz ).z));
				float3 break252_g1339 = v.positionOS.xyz;
				float3 appendResult255_g1339 = (float3(break252_g1339.x , ( break252_g1339.y * 0.15 ) , 0.0));
				float mulTime263_g1339 = _TimeParameters.x * 2.1;
				float3 temp_cast_0 = (v.positionOS.xyz.y).xxx;
				float2 appendResult300_g1339 = (float2(v.positionOS.xyz.x , v.positionOS.xyz.z));
				float3 temp_output_303_0_g1339 = ( cross( temp_cast_0 , float3( appendResult300_g1339 ,  0.0 ) ) * 0.005 );
				float3 appendResult270_g1339 = (float3(0.0 , v.positionOS.xyz.y , 0.0));
				float3 break269_g1339 = v.positionOS.xyz;
				float3 appendResult271_g1339 = (float3(break269_g1339.x , 0.0 , ( break269_g1339.z * 0.15 )));
				float mulTime282_g1339 = _TimeParameters.x * 2.3;
				float3 appendResult293_g1339 = (float3(v.positionOS.xyz.x , 0.0 , 0.0));
				float3 break288_g1339 = v.positionOS.xyz;
				float3 appendResult292_g1339 = (float3(0.0 , ( break288_g1339.y * 0.2 ) , ( break288_g1339.z * 0.4 )));
				float mulTime249_g1339 = _TimeParameters.x * 2.0;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float3 normalizeResult155_g1339 = normalize( ase_worldPos );
				float mulTime161_g1339 = _TimeParameters.x * 0.25;
				float simplePerlin2D159_g1339 = snoise( ( normalizeResult155_g1339 + mulTime161_g1339 ).xy*0.43 );
				float WindMask_LargeB169_g1339 = ( simplePerlin2D159_g1339 * 1.5 );
				float3 normalizeResult162_g1339 = normalize( ase_worldPos );
				float mulTime167_g1339 = _TimeParameters.x * 0.26;
				float simplePerlin2D166_g1339 = snoise( ( normalizeResult162_g1339 + mulTime167_g1339 ).xy*0.7 );
				float WindMask_LargeC170_g1339 = ( simplePerlin2D166_g1339 * 1.5 );
				float mulTime133_g1339 = _TimeParameters.x * 3.2;
				float3 worldToObj126_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_135_0_g1339 = ( mulTime133_g1339 + ( 0.02 * worldToObj126_g1339.x ) + ( worldToObj126_g1339.y * 0.14 ) + ( worldToObj126_g1339.z * 0.16 ) + float3(0.4,0.3,0.1) );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float mulTime111_g1339 = _TimeParameters.x * 2.3;
				float3 worldToObj103_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_106_0_g1339 = ( mulTime111_g1339 + ( 0.2 * worldToObj103_g1339 ) + float3(0.4,0.3,0.1) );
				float mulTime118_g1339 = _TimeParameters.x * 3.6;
				float3 temp_cast_4 = (v.positionOS.xyz.x).xxx;
				float3 worldToObj114_g1339 = mul( GetWorldToObjectMatrix(), float4( temp_cast_4, 1 ) ).xyz;
				float temp_output_119_0_g1339 = ( mulTime118_g1339 + ( 0.2 * worldToObj114_g1339.x ) );
				float3 temp_cast_5 = (0.0).xxx;
				#if defined(_WINDTYPE_GENTLEBREEZE)
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#elif defined(_WINDTYPE_WINDOFF)
				float3 staticSwitch312_g1339 = temp_cast_5;
				#else
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#endif
				
				o.ase_texcoord4.xy = v.texcoord0.xy;
				o.ase_texcoord5 = v.positionOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( _GlobalWindStrength * staticSwitch312_g1339 );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = positionWS;
				#endif

				o.positionCS = MetaVertexPosition( v.positionOS, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );

				#ifdef EDITOR_VISUALIZATION
					float2 VizUV = 0;
					float4 LightCoord = 0;
					UnityEditorVizData(v.positionOS.xyz, v.texcoord0.xy, v.texcoord1.xy, v.texcoord2.xy, VizUV, LightCoord);
					o.VizUV = float4(VizUV, 0, 0);
					o.LightCoord = LightCoord;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.texcoord0 = v.texcoord0;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.texcoord0 = patch[0].texcoord0 * bary.x + patch[1].texcoord0 * bary.y + patch[2].texcoord0 * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_AlbedoMap81_g1335 = IN.ase_texcoord4.xy;
				float2 uv_AlbedoMap83_g1335 = IN.ase_texcoord4.xy;
				float4 tex2DNode83_g1335 = tex2D( _AlbedoMap, uv_AlbedoMap83_g1335 );
				float2 uv_NoiseMapGrayscale98_g1335 = IN.ase_texcoord4.xy;
				float4 transform94_g1335 = mul(GetObjectToWorldMatrix(),float4( 1,1,1,1 ));
				float dotResult4_g1337 = dot( transform94_g1335.xy , float2( 12.9898,78.233 ) );
				float lerpResult10_g1337 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1337 ) * 43758.55 ) ));
				float3 normalizeResult120_g1335 = normalize( IN.ase_texcoord5.xyz );
				float DryLeafPositionMask124_g1335 = ( (distance( normalizeResult120_g1335 , float3( 0,0.8,0 ) )*1.0 + 0.0) * 1 );
				float4 lerpResult46_g1335 = lerp( ( _DryLeafColor * ( tex2DNode83_g1335.g * 2 ) ) , tex2DNode83_g1335 , saturate( (( ( tex2D( _NoiseMapGrayscale, uv_NoiseMapGrayscale98_g1335 ).r * lerpResult10_g1337 * DryLeafPositionMask124_g1335 ) - _SeasonChangeGlobal )*_DryLeavesScale + _DryLeavesOffset) ));
				float4 SeasonControl_Output88_g1335 = lerpResult46_g1335;
				Gradient gradient60_g1335 = NewGradient( 0, 2, 2, float4( 1, 0.276868, 0, 0 ), float4( 0, 1, 0.7818019, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float4 transform62_g1335 = mul(GetObjectToWorldMatrix(),float4( 1,1,1,1 ));
				float dotResult4_g1336 = dot( transform62_g1335.xy , float2( 12.9898,78.233 ) );
				float lerpResult10_g1336 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1336 ) * 43758.55 ) ));
				float4 lerpResult70_g1335 = lerp( SeasonControl_Output88_g1335 , ( ( SeasonControl_Output88_g1335 * 0.5 ) + ( SampleGradient( gradient60_g1335, lerpResult10_g1336 ) * SeasonControl_Output88_g1335 ) ) , _ColorVariation);
				float2 uv_MaskMapRGBA82_g1335 = IN.ase_texcoord4.xy;
				float4 lerpResult78_g1335 = lerp( tex2D( _AlbedoMap, uv_AlbedoMap81_g1335 ) , lerpResult70_g1335 , (( _BranchMaskR )?( tex2D( _MaskMapRGBA, uv_MaskMapRGBA82_g1335 ).r ):( 1.0 )));
				float3 temp_output_104_0_g1335 = ( ( IN.ase_texcoord5.xyz * float3( 2,1.3,2 ) ) / 25.0 );
				float dotResult107_g1335 = dot( temp_output_104_0_g1335 , temp_output_104_0_g1335 );
				float3 normalizeResult103_g1335 = normalize( IN.ase_texcoord5.xyz );
				float SelfShading115_g1335 = saturate( (( pow( abs( saturate( dotResult107_g1335 ) ) , 1.5 ) + ( ( 1.0 - (distance( normalizeResult103_g1335 , float3( 0,0.8,0 ) )*0.5 + 0.0) ) * 0.6 ) )*0.92 + -0.16) );
				#ifdef _SELFSHADING_ON
				float4 staticSwitch74_g1335 = ( lerpResult78_g1335 * (SelfShading115_g1335*_VertexLighting + _VertexShadow) );
				#else
				float4 staticSwitch74_g1335 = lerpResult78_g1335;
				#endif
				float4 LeafColorVariationSeasons_Output91_g1335 = staticSwitch74_g1335;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult151_g1335 = dot( ase_worldViewDir , -( _MainLightPosition.xyz + IN.ase_texcoord5.xyz ) );
				float2 uv_MaskMapRGBA152_g1335 = IN.ase_texcoord4.xy;
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float TobyTranslucency153_g1335 = ( saturate( dotResult151_g1335 ) * tex2D( _MaskMapRGBA, uv_MaskMapRGBA152_g1335 ).b * ase_lightColor.a );
				float TranslucencyIntensity39_g1335 = _TranslucencyPower;
				float4 Albedo_Output154_g1335 = ( ( _AlebedoColor * LeafColorVariationSeasons_Output91_g1335 ) * (1.0 + (TobyTranslucency153_g1335 - 0.0) * (TranslucencyIntensity39_g1335 - 1.0) / (1.0 - 0.0)) );
				
				float2 uv_AlbedoMap80_g1335 = IN.ase_texcoord4.xy;
				float Opacity_Output86_g1335 = ( 1.0 - tex2D( _AlbedoMap, uv_AlbedoMap80_g1335 ).a );
				

				float3 BaseColor = Albedo_Output154_g1335.rgb;
				float3 Emission = 0;
				float Alpha = 1;
				float AlphaClipThreshold = ( Opacity_Output86_g1335 * 1.4 );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;
				#ifdef EDITOR_VISUALIZATION
					metaInput.VizUV = IN.VizUV.xy;
					metaInput.LightCoord = IN.LightCoord;
				#endif

				return UnityMetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120107


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _WINDTYPE_GENTLEBREEZE _WINDTYPE_WINDOFF
			#pragma shader_feature_local _SELFSHADING_ON


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AlebedoColor;
			float4 _DryLeafColor;
			float _GlobalWindStrength;
			float _SeasonChangeGlobal;
			float _DryLeavesScale;
			float _DryLeavesOffset;
			float _ColorVariation;
			float _BranchMaskR;
			float _VertexLighting;
			float _VertexShadow;
			float _TranslucencyPower;
			float _NormalIntenisty;
			float _SmoothnessIntensity;
			float _AmbientOcclusionIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AlbedoMap;
			sampler2D _NoiseMapGrayscale;
			sampler2D _MaskMapRGBA;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 appendResult256_g1339 = (float3(0.0 , 0.0 , saturate( v.positionOS.xyz ).z));
				float3 break252_g1339 = v.positionOS.xyz;
				float3 appendResult255_g1339 = (float3(break252_g1339.x , ( break252_g1339.y * 0.15 ) , 0.0));
				float mulTime263_g1339 = _TimeParameters.x * 2.1;
				float3 temp_cast_0 = (v.positionOS.xyz.y).xxx;
				float2 appendResult300_g1339 = (float2(v.positionOS.xyz.x , v.positionOS.xyz.z));
				float3 temp_output_303_0_g1339 = ( cross( temp_cast_0 , float3( appendResult300_g1339 ,  0.0 ) ) * 0.005 );
				float3 appendResult270_g1339 = (float3(0.0 , v.positionOS.xyz.y , 0.0));
				float3 break269_g1339 = v.positionOS.xyz;
				float3 appendResult271_g1339 = (float3(break269_g1339.x , 0.0 , ( break269_g1339.z * 0.15 )));
				float mulTime282_g1339 = _TimeParameters.x * 2.3;
				float3 appendResult293_g1339 = (float3(v.positionOS.xyz.x , 0.0 , 0.0));
				float3 break288_g1339 = v.positionOS.xyz;
				float3 appendResult292_g1339 = (float3(0.0 , ( break288_g1339.y * 0.2 ) , ( break288_g1339.z * 0.4 )));
				float mulTime249_g1339 = _TimeParameters.x * 2.0;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float3 normalizeResult155_g1339 = normalize( ase_worldPos );
				float mulTime161_g1339 = _TimeParameters.x * 0.25;
				float simplePerlin2D159_g1339 = snoise( ( normalizeResult155_g1339 + mulTime161_g1339 ).xy*0.43 );
				float WindMask_LargeB169_g1339 = ( simplePerlin2D159_g1339 * 1.5 );
				float3 normalizeResult162_g1339 = normalize( ase_worldPos );
				float mulTime167_g1339 = _TimeParameters.x * 0.26;
				float simplePerlin2D166_g1339 = snoise( ( normalizeResult162_g1339 + mulTime167_g1339 ).xy*0.7 );
				float WindMask_LargeC170_g1339 = ( simplePerlin2D166_g1339 * 1.5 );
				float mulTime133_g1339 = _TimeParameters.x * 3.2;
				float3 worldToObj126_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_135_0_g1339 = ( mulTime133_g1339 + ( 0.02 * worldToObj126_g1339.x ) + ( worldToObj126_g1339.y * 0.14 ) + ( worldToObj126_g1339.z * 0.16 ) + float3(0.4,0.3,0.1) );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float mulTime111_g1339 = _TimeParameters.x * 2.3;
				float3 worldToObj103_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_106_0_g1339 = ( mulTime111_g1339 + ( 0.2 * worldToObj103_g1339 ) + float3(0.4,0.3,0.1) );
				float mulTime118_g1339 = _TimeParameters.x * 3.6;
				float3 temp_cast_4 = (v.positionOS.xyz.x).xxx;
				float3 worldToObj114_g1339 = mul( GetWorldToObjectMatrix(), float4( temp_cast_4, 1 ) ).xyz;
				float temp_output_119_0_g1339 = ( mulTime118_g1339 + ( 0.2 * worldToObj114_g1339.x ) );
				float3 temp_cast_5 = (0.0).xxx;
				#if defined(_WINDTYPE_GENTLEBREEZE)
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#elif defined(_WINDTYPE_WINDOFF)
				float3 staticSwitch312_g1339 = temp_cast_5;
				#else
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#endif
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.positionOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( _GlobalWindStrength * staticSwitch312_g1339 );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = vertexInput.positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_AlbedoMap81_g1335 = IN.ase_texcoord2.xy;
				float2 uv_AlbedoMap83_g1335 = IN.ase_texcoord2.xy;
				float4 tex2DNode83_g1335 = tex2D( _AlbedoMap, uv_AlbedoMap83_g1335 );
				float2 uv_NoiseMapGrayscale98_g1335 = IN.ase_texcoord2.xy;
				float4 transform94_g1335 = mul(GetObjectToWorldMatrix(),float4( 1,1,1,1 ));
				float dotResult4_g1337 = dot( transform94_g1335.xy , float2( 12.9898,78.233 ) );
				float lerpResult10_g1337 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1337 ) * 43758.55 ) ));
				float3 normalizeResult120_g1335 = normalize( IN.ase_texcoord3.xyz );
				float DryLeafPositionMask124_g1335 = ( (distance( normalizeResult120_g1335 , float3( 0,0.8,0 ) )*1.0 + 0.0) * 1 );
				float4 lerpResult46_g1335 = lerp( ( _DryLeafColor * ( tex2DNode83_g1335.g * 2 ) ) , tex2DNode83_g1335 , saturate( (( ( tex2D( _NoiseMapGrayscale, uv_NoiseMapGrayscale98_g1335 ).r * lerpResult10_g1337 * DryLeafPositionMask124_g1335 ) - _SeasonChangeGlobal )*_DryLeavesScale + _DryLeavesOffset) ));
				float4 SeasonControl_Output88_g1335 = lerpResult46_g1335;
				Gradient gradient60_g1335 = NewGradient( 0, 2, 2, float4( 1, 0.276868, 0, 0 ), float4( 0, 1, 0.7818019, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float4 transform62_g1335 = mul(GetObjectToWorldMatrix(),float4( 1,1,1,1 ));
				float dotResult4_g1336 = dot( transform62_g1335.xy , float2( 12.9898,78.233 ) );
				float lerpResult10_g1336 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1336 ) * 43758.55 ) ));
				float4 lerpResult70_g1335 = lerp( SeasonControl_Output88_g1335 , ( ( SeasonControl_Output88_g1335 * 0.5 ) + ( SampleGradient( gradient60_g1335, lerpResult10_g1336 ) * SeasonControl_Output88_g1335 ) ) , _ColorVariation);
				float2 uv_MaskMapRGBA82_g1335 = IN.ase_texcoord2.xy;
				float4 lerpResult78_g1335 = lerp( tex2D( _AlbedoMap, uv_AlbedoMap81_g1335 ) , lerpResult70_g1335 , (( _BranchMaskR )?( tex2D( _MaskMapRGBA, uv_MaskMapRGBA82_g1335 ).r ):( 1.0 )));
				float3 temp_output_104_0_g1335 = ( ( IN.ase_texcoord3.xyz * float3( 2,1.3,2 ) ) / 25.0 );
				float dotResult107_g1335 = dot( temp_output_104_0_g1335 , temp_output_104_0_g1335 );
				float3 normalizeResult103_g1335 = normalize( IN.ase_texcoord3.xyz );
				float SelfShading115_g1335 = saturate( (( pow( abs( saturate( dotResult107_g1335 ) ) , 1.5 ) + ( ( 1.0 - (distance( normalizeResult103_g1335 , float3( 0,0.8,0 ) )*0.5 + 0.0) ) * 0.6 ) )*0.92 + -0.16) );
				#ifdef _SELFSHADING_ON
				float4 staticSwitch74_g1335 = ( lerpResult78_g1335 * (SelfShading115_g1335*_VertexLighting + _VertexShadow) );
				#else
				float4 staticSwitch74_g1335 = lerpResult78_g1335;
				#endif
				float4 LeafColorVariationSeasons_Output91_g1335 = staticSwitch74_g1335;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult151_g1335 = dot( ase_worldViewDir , -( _MainLightPosition.xyz + IN.ase_texcoord3.xyz ) );
				float2 uv_MaskMapRGBA152_g1335 = IN.ase_texcoord2.xy;
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float TobyTranslucency153_g1335 = ( saturate( dotResult151_g1335 ) * tex2D( _MaskMapRGBA, uv_MaskMapRGBA152_g1335 ).b * ase_lightColor.a );
				float TranslucencyIntensity39_g1335 = _TranslucencyPower;
				float4 Albedo_Output154_g1335 = ( ( _AlebedoColor * LeafColorVariationSeasons_Output91_g1335 ) * (1.0 + (TobyTranslucency153_g1335 - 0.0) * (TranslucencyIntensity39_g1335 - 1.0) / (1.0 - 0.0)) );
				
				float2 uv_AlbedoMap80_g1335 = IN.ase_texcoord2.xy;
				float Opacity_Output86_g1335 = ( 1.0 - tex2D( _AlbedoMap, uv_AlbedoMap80_g1335 ).a );
				

				float3 BaseColor = Albedo_Output154_g1335.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = ( Opacity_Output86_g1335 * 1.4 );

				half4 color = half4(BaseColor, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120107


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _WINDTYPE_GENTLEBREEZE _WINDTYPE_WINDOFF


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 worldTangent : TEXCOORD2;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD3;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD4;
				#endif
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AlebedoColor;
			float4 _DryLeafColor;
			float _GlobalWindStrength;
			float _SeasonChangeGlobal;
			float _DryLeavesScale;
			float _DryLeavesOffset;
			float _ColorVariation;
			float _BranchMaskR;
			float _VertexLighting;
			float _VertexShadow;
			float _TranslucencyPower;
			float _NormalIntenisty;
			float _SmoothnessIntensity;
			float _AmbientOcclusionIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _NormalMap;
			sampler2D _AlbedoMap;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult256_g1339 = (float3(0.0 , 0.0 , saturate( v.positionOS.xyz ).z));
				float3 break252_g1339 = v.positionOS.xyz;
				float3 appendResult255_g1339 = (float3(break252_g1339.x , ( break252_g1339.y * 0.15 ) , 0.0));
				float mulTime263_g1339 = _TimeParameters.x * 2.1;
				float3 temp_cast_0 = (v.positionOS.xyz.y).xxx;
				float2 appendResult300_g1339 = (float2(v.positionOS.xyz.x , v.positionOS.xyz.z));
				float3 temp_output_303_0_g1339 = ( cross( temp_cast_0 , float3( appendResult300_g1339 ,  0.0 ) ) * 0.005 );
				float3 appendResult270_g1339 = (float3(0.0 , v.positionOS.xyz.y , 0.0));
				float3 break269_g1339 = v.positionOS.xyz;
				float3 appendResult271_g1339 = (float3(break269_g1339.x , 0.0 , ( break269_g1339.z * 0.15 )));
				float mulTime282_g1339 = _TimeParameters.x * 2.3;
				float3 appendResult293_g1339 = (float3(v.positionOS.xyz.x , 0.0 , 0.0));
				float3 break288_g1339 = v.positionOS.xyz;
				float3 appendResult292_g1339 = (float3(0.0 , ( break288_g1339.y * 0.2 ) , ( break288_g1339.z * 0.4 )));
				float mulTime249_g1339 = _TimeParameters.x * 2.0;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float3 normalizeResult155_g1339 = normalize( ase_worldPos );
				float mulTime161_g1339 = _TimeParameters.x * 0.25;
				float simplePerlin2D159_g1339 = snoise( ( normalizeResult155_g1339 + mulTime161_g1339 ).xy*0.43 );
				float WindMask_LargeB169_g1339 = ( simplePerlin2D159_g1339 * 1.5 );
				float3 normalizeResult162_g1339 = normalize( ase_worldPos );
				float mulTime167_g1339 = _TimeParameters.x * 0.26;
				float simplePerlin2D166_g1339 = snoise( ( normalizeResult162_g1339 + mulTime167_g1339 ).xy*0.7 );
				float WindMask_LargeC170_g1339 = ( simplePerlin2D166_g1339 * 1.5 );
				float mulTime133_g1339 = _TimeParameters.x * 3.2;
				float3 worldToObj126_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_135_0_g1339 = ( mulTime133_g1339 + ( 0.02 * worldToObj126_g1339.x ) + ( worldToObj126_g1339.y * 0.14 ) + ( worldToObj126_g1339.z * 0.16 ) + float3(0.4,0.3,0.1) );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float mulTime111_g1339 = _TimeParameters.x * 2.3;
				float3 worldToObj103_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_106_0_g1339 = ( mulTime111_g1339 + ( 0.2 * worldToObj103_g1339 ) + float3(0.4,0.3,0.1) );
				float mulTime118_g1339 = _TimeParameters.x * 3.6;
				float3 temp_cast_4 = (v.positionOS.xyz.x).xxx;
				float3 worldToObj114_g1339 = mul( GetWorldToObjectMatrix(), float4( temp_cast_4, 1 ) ).xyz;
				float temp_output_119_0_g1339 = ( mulTime118_g1339 + ( 0.2 * worldToObj114_g1339.x ) );
				float3 temp_cast_5 = (0.0).xxx;
				#if defined(_WINDTYPE_GENTLEBREEZE)
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#elif defined(_WINDTYPE_WINDOFF)
				float3 staticSwitch312_g1339 = temp_cast_5;
				#else
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#endif
				
				o.ase_texcoord5.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( _GlobalWindStrength * staticSwitch312_g1339 );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;
				v.tangentOS = v.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );

				float3 normalWS = TransformObjectToWorldNormal( v.normalOS );
				float4 tangentWS = float4( TransformObjectToWorldDir( v.tangentOS.xyz ), v.tangentOS.w );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = vertexInput.positionWS;
				#endif

				o.worldNormal = normalWS;
				o.worldTangent = tangentWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;
				o.clipPosV = vertexInput.positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.tangentOS = v.tangentOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float3 WorldNormal = IN.worldNormal;
				float4 WorldTangent = IN.worldTangent;

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_NormalMap87_g1335 = IN.ase_texcoord5.xy;
				float3 unpack87_g1335 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap87_g1335 ), _NormalIntenisty );
				unpack87_g1335.z = lerp( 1, unpack87_g1335.z, saturate(_NormalIntenisty) );
				float3 Normal_Output155_g1335 = unpack87_g1335;
				
				float2 uv_AlbedoMap80_g1335 = IN.ase_texcoord5.xy;
				float Opacity_Output86_g1335 = ( 1.0 - tex2D( _AlbedoMap, uv_AlbedoMap80_g1335 ).a );
				

				float3 Normal = Normal_Output155_g1335;
				float Alpha = 1;
				float AlphaClipThreshold = ( Opacity_Output86_g1335 * 1.4 );

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(WorldNormal);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					return half4(packedNormalWS, 0.0);
				#else
					#if defined(_NORMALMAP)
						#if _NORMAL_DROPOFF_TS
							float crossSign = (WorldTangent.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
							float3 bitangent = crossSign * cross(WorldNormal.xyz, WorldTangent.xyz);
							float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent.xyz, bitangent, WorldNormal.xyz));
						#elif _NORMAL_DROPOFF_OS
							float3 normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							float3 normalWS = Normal;
						#endif
					#else
						float3 normalWS = WorldNormal;
					#endif
					return half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120107


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#pragma shader_feature_local _WINDTYPE_GENTLEBREEZE _WINDTYPE_WINDOFF
			#pragma shader_feature_local _SELFSHADING_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
				float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AlebedoColor;
			float4 _DryLeafColor;
			float _GlobalWindStrength;
			float _SeasonChangeGlobal;
			float _DryLeavesScale;
			float _DryLeavesOffset;
			float _ColorVariation;
			float _BranchMaskR;
			float _VertexLighting;
			float _VertexShadow;
			float _TranslucencyPower;
			float _NormalIntenisty;
			float _SmoothnessIntensity;
			float _AmbientOcclusionIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AlbedoMap;
			sampler2D _NoiseMapGrayscale;
			sampler2D _MaskMapRGBA;
			sampler2D _NormalMap;


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult256_g1339 = (float3(0.0 , 0.0 , saturate( v.positionOS.xyz ).z));
				float3 break252_g1339 = v.positionOS.xyz;
				float3 appendResult255_g1339 = (float3(break252_g1339.x , ( break252_g1339.y * 0.15 ) , 0.0));
				float mulTime263_g1339 = _TimeParameters.x * 2.1;
				float3 temp_cast_0 = (v.positionOS.xyz.y).xxx;
				float2 appendResult300_g1339 = (float2(v.positionOS.xyz.x , v.positionOS.xyz.z));
				float3 temp_output_303_0_g1339 = ( cross( temp_cast_0 , float3( appendResult300_g1339 ,  0.0 ) ) * 0.005 );
				float3 appendResult270_g1339 = (float3(0.0 , v.positionOS.xyz.y , 0.0));
				float3 break269_g1339 = v.positionOS.xyz;
				float3 appendResult271_g1339 = (float3(break269_g1339.x , 0.0 , ( break269_g1339.z * 0.15 )));
				float mulTime282_g1339 = _TimeParameters.x * 2.3;
				float3 appendResult293_g1339 = (float3(v.positionOS.xyz.x , 0.0 , 0.0));
				float3 break288_g1339 = v.positionOS.xyz;
				float3 appendResult292_g1339 = (float3(0.0 , ( break288_g1339.y * 0.2 ) , ( break288_g1339.z * 0.4 )));
				float mulTime249_g1339 = _TimeParameters.x * 2.0;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float3 normalizeResult155_g1339 = normalize( ase_worldPos );
				float mulTime161_g1339 = _TimeParameters.x * 0.25;
				float simplePerlin2D159_g1339 = snoise( ( normalizeResult155_g1339 + mulTime161_g1339 ).xy*0.43 );
				float WindMask_LargeB169_g1339 = ( simplePerlin2D159_g1339 * 1.5 );
				float3 normalizeResult162_g1339 = normalize( ase_worldPos );
				float mulTime167_g1339 = _TimeParameters.x * 0.26;
				float simplePerlin2D166_g1339 = snoise( ( normalizeResult162_g1339 + mulTime167_g1339 ).xy*0.7 );
				float WindMask_LargeC170_g1339 = ( simplePerlin2D166_g1339 * 1.5 );
				float mulTime133_g1339 = _TimeParameters.x * 3.2;
				float3 worldToObj126_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_135_0_g1339 = ( mulTime133_g1339 + ( 0.02 * worldToObj126_g1339.x ) + ( worldToObj126_g1339.y * 0.14 ) + ( worldToObj126_g1339.z * 0.16 ) + float3(0.4,0.3,0.1) );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float mulTime111_g1339 = _TimeParameters.x * 2.3;
				float3 worldToObj103_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_106_0_g1339 = ( mulTime111_g1339 + ( 0.2 * worldToObj103_g1339 ) + float3(0.4,0.3,0.1) );
				float mulTime118_g1339 = _TimeParameters.x * 3.6;
				float3 temp_cast_4 = (v.positionOS.xyz.x).xxx;
				float3 worldToObj114_g1339 = mul( GetWorldToObjectMatrix(), float4( temp_cast_4, 1 ) ).xyz;
				float temp_output_119_0_g1339 = ( mulTime118_g1339 + ( 0.2 * worldToObj114_g1339.x ) );
				float3 temp_cast_5 = (0.0).xxx;
				#if defined(_WINDTYPE_GENTLEBREEZE)
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#elif defined(_WINDTYPE_WINDOFF)
				float3 staticSwitch312_g1339 = temp_cast_5;
				#else
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#endif
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_texcoord9 = v.positionOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( _GlobalWindStrength * staticSwitch312_g1339 );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;
				v.tangentOS = v.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( v.normalOS, v.tangentOS );

				o.tSpace0 = float4( normalInput.normalWS, vertexInput.positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, vertexInput.positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, vertexInput.positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord.xy;
					o.lightmapUVOrVertexSH.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );

				o.fogFactorAndVertexLight = half4(0, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;
				o.clipPosV = vertexInput.positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.tangentOS = v.tangentOS;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			FragmentOutput frag ( VertexOutput IN
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionCS);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#else
					ShadowCoords = float4(0, 0, 0, 0);
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_AlbedoMap81_g1335 = IN.ase_texcoord8.xy;
				float2 uv_AlbedoMap83_g1335 = IN.ase_texcoord8.xy;
				float4 tex2DNode83_g1335 = tex2D( _AlbedoMap, uv_AlbedoMap83_g1335 );
				float2 uv_NoiseMapGrayscale98_g1335 = IN.ase_texcoord8.xy;
				float4 transform94_g1335 = mul(GetObjectToWorldMatrix(),float4( 1,1,1,1 ));
				float dotResult4_g1337 = dot( transform94_g1335.xy , float2( 12.9898,78.233 ) );
				float lerpResult10_g1337 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1337 ) * 43758.55 ) ));
				float3 normalizeResult120_g1335 = normalize( IN.ase_texcoord9.xyz );
				float DryLeafPositionMask124_g1335 = ( (distance( normalizeResult120_g1335 , float3( 0,0.8,0 ) )*1.0 + 0.0) * 1 );
				float4 lerpResult46_g1335 = lerp( ( _DryLeafColor * ( tex2DNode83_g1335.g * 2 ) ) , tex2DNode83_g1335 , saturate( (( ( tex2D( _NoiseMapGrayscale, uv_NoiseMapGrayscale98_g1335 ).r * lerpResult10_g1337 * DryLeafPositionMask124_g1335 ) - _SeasonChangeGlobal )*_DryLeavesScale + _DryLeavesOffset) ));
				float4 SeasonControl_Output88_g1335 = lerpResult46_g1335;
				Gradient gradient60_g1335 = NewGradient( 0, 2, 2, float4( 1, 0.276868, 0, 0 ), float4( 0, 1, 0.7818019, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float4 transform62_g1335 = mul(GetObjectToWorldMatrix(),float4( 1,1,1,1 ));
				float dotResult4_g1336 = dot( transform62_g1335.xy , float2( 12.9898,78.233 ) );
				float lerpResult10_g1336 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1336 ) * 43758.55 ) ));
				float4 lerpResult70_g1335 = lerp( SeasonControl_Output88_g1335 , ( ( SeasonControl_Output88_g1335 * 0.5 ) + ( SampleGradient( gradient60_g1335, lerpResult10_g1336 ) * SeasonControl_Output88_g1335 ) ) , _ColorVariation);
				float2 uv_MaskMapRGBA82_g1335 = IN.ase_texcoord8.xy;
				float4 lerpResult78_g1335 = lerp( tex2D( _AlbedoMap, uv_AlbedoMap81_g1335 ) , lerpResult70_g1335 , (( _BranchMaskR )?( tex2D( _MaskMapRGBA, uv_MaskMapRGBA82_g1335 ).r ):( 1.0 )));
				float3 temp_output_104_0_g1335 = ( ( IN.ase_texcoord9.xyz * float3( 2,1.3,2 ) ) / 25.0 );
				float dotResult107_g1335 = dot( temp_output_104_0_g1335 , temp_output_104_0_g1335 );
				float3 normalizeResult103_g1335 = normalize( IN.ase_texcoord9.xyz );
				float SelfShading115_g1335 = saturate( (( pow( abs( saturate( dotResult107_g1335 ) ) , 1.5 ) + ( ( 1.0 - (distance( normalizeResult103_g1335 , float3( 0,0.8,0 ) )*0.5 + 0.0) ) * 0.6 ) )*0.92 + -0.16) );
				#ifdef _SELFSHADING_ON
				float4 staticSwitch74_g1335 = ( lerpResult78_g1335 * (SelfShading115_g1335*_VertexLighting + _VertexShadow) );
				#else
				float4 staticSwitch74_g1335 = lerpResult78_g1335;
				#endif
				float4 LeafColorVariationSeasons_Output91_g1335 = staticSwitch74_g1335;
				float dotResult151_g1335 = dot( WorldViewDirection , -( _MainLightPosition.xyz + IN.ase_texcoord9.xyz ) );
				float2 uv_MaskMapRGBA152_g1335 = IN.ase_texcoord8.xy;
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float TobyTranslucency153_g1335 = ( saturate( dotResult151_g1335 ) * tex2D( _MaskMapRGBA, uv_MaskMapRGBA152_g1335 ).b * ase_lightColor.a );
				float TranslucencyIntensity39_g1335 = _TranslucencyPower;
				float4 Albedo_Output154_g1335 = ( ( _AlebedoColor * LeafColorVariationSeasons_Output91_g1335 ) * (1.0 + (TobyTranslucency153_g1335 - 0.0) * (TranslucencyIntensity39_g1335 - 1.0) / (1.0 - 0.0)) );
				
				float2 uv_NormalMap87_g1335 = IN.ase_texcoord8.xy;
				float3 unpack87_g1335 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap87_g1335 ), _NormalIntenisty );
				unpack87_g1335.z = lerp( 1, unpack87_g1335.z, saturate(_NormalIntenisty) );
				float3 Normal_Output155_g1335 = unpack87_g1335;
				
				float2 uv_MaskMapRGBA79_g1335 = IN.ase_texcoord8.xy;
				float4 tex2DNode79_g1335 = tex2D( _MaskMapRGBA, uv_MaskMapRGBA79_g1335 );
				float Smoothness_Output35_g1335 = ( tex2DNode79_g1335.a * _SmoothnessIntensity );
				
				float AoMapBase31_g1335 = tex2DNode79_g1335.g;
				float Ao_Output141_g1335 = ( pow( abs( AoMapBase31_g1335 ) , _AmbientOcclusionIntensity ) * ( 1.5 / ( ( saturate( TobyTranslucency153_g1335 ) * TranslucencyIntensity39_g1335 ) + 1.5 ) ) );
				
				float2 uv_AlbedoMap80_g1335 = IN.ase_texcoord8.xy;
				float Opacity_Output86_g1335 = ( 1.0 - tex2D( _AlbedoMap, uv_AlbedoMap80_g1335 ).a );
				

				float3 BaseColor = Albedo_Output154_g1335.rgb;
				float3 Normal = Normal_Output155_g1335;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = Smoothness_Output35_g1335;
				float Occlusion = Ao_Output141_g1335;
				float Alpha = 1;
				float AlphaClipThreshold = ( Opacity_Output86_g1335 * 1.4 );
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.positionCS = IN.positionCS;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
						inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
						inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
						inputData.normalWS = Normal;
					#endif
				#else
					inputData.normalWS = WorldNormal;
				#endif

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				inputData.viewDirectionWS = SafeNormalize( WorldViewDirection );

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#else
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
					#else
						inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
						#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				#ifdef _DBUFFER
					ApplyDecal(IN.positionCS,
						BaseColor,
						Specular,
						inputData.normalWS,
						Metallic,
						Occlusion,
						Smoothness);
				#endif

				BRDFData brdfData;
				InitializeBRDFData
				(BaseColor, Metallic, Specular, Smoothness, Alpha, brdfData);

				Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
				half4 color;
				MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
				color.rgb = GlobalIllumination(brdfData, inputData.bakedGI, Occlusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb, Occlusion);
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off
			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120107


			#pragma vertex vert
			#pragma fragment frag

			#define SCENESELECTIONPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _WINDTYPE_GENTLEBREEZE _WINDTYPE_WINDOFF


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AlebedoColor;
			float4 _DryLeafColor;
			float _GlobalWindStrength;
			float _SeasonChangeGlobal;
			float _DryLeavesScale;
			float _DryLeavesOffset;
			float _ColorVariation;
			float _BranchMaskR;
			float _VertexLighting;
			float _VertexShadow;
			float _TranslucencyPower;
			float _NormalIntenisty;
			float _SmoothnessIntensity;
			float _AmbientOcclusionIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AlbedoMap;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult256_g1339 = (float3(0.0 , 0.0 , saturate( v.positionOS.xyz ).z));
				float3 break252_g1339 = v.positionOS.xyz;
				float3 appendResult255_g1339 = (float3(break252_g1339.x , ( break252_g1339.y * 0.15 ) , 0.0));
				float mulTime263_g1339 = _TimeParameters.x * 2.1;
				float3 temp_cast_0 = (v.positionOS.xyz.y).xxx;
				float2 appendResult300_g1339 = (float2(v.positionOS.xyz.x , v.positionOS.xyz.z));
				float3 temp_output_303_0_g1339 = ( cross( temp_cast_0 , float3( appendResult300_g1339 ,  0.0 ) ) * 0.005 );
				float3 appendResult270_g1339 = (float3(0.0 , v.positionOS.xyz.y , 0.0));
				float3 break269_g1339 = v.positionOS.xyz;
				float3 appendResult271_g1339 = (float3(break269_g1339.x , 0.0 , ( break269_g1339.z * 0.15 )));
				float mulTime282_g1339 = _TimeParameters.x * 2.3;
				float3 appendResult293_g1339 = (float3(v.positionOS.xyz.x , 0.0 , 0.0));
				float3 break288_g1339 = v.positionOS.xyz;
				float3 appendResult292_g1339 = (float3(0.0 , ( break288_g1339.y * 0.2 ) , ( break288_g1339.z * 0.4 )));
				float mulTime249_g1339 = _TimeParameters.x * 2.0;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float3 normalizeResult155_g1339 = normalize( ase_worldPos );
				float mulTime161_g1339 = _TimeParameters.x * 0.25;
				float simplePerlin2D159_g1339 = snoise( ( normalizeResult155_g1339 + mulTime161_g1339 ).xy*0.43 );
				float WindMask_LargeB169_g1339 = ( simplePerlin2D159_g1339 * 1.5 );
				float3 normalizeResult162_g1339 = normalize( ase_worldPos );
				float mulTime167_g1339 = _TimeParameters.x * 0.26;
				float simplePerlin2D166_g1339 = snoise( ( normalizeResult162_g1339 + mulTime167_g1339 ).xy*0.7 );
				float WindMask_LargeC170_g1339 = ( simplePerlin2D166_g1339 * 1.5 );
				float mulTime133_g1339 = _TimeParameters.x * 3.2;
				float3 worldToObj126_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_135_0_g1339 = ( mulTime133_g1339 + ( 0.02 * worldToObj126_g1339.x ) + ( worldToObj126_g1339.y * 0.14 ) + ( worldToObj126_g1339.z * 0.16 ) + float3(0.4,0.3,0.1) );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float mulTime111_g1339 = _TimeParameters.x * 2.3;
				float3 worldToObj103_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_106_0_g1339 = ( mulTime111_g1339 + ( 0.2 * worldToObj103_g1339 ) + float3(0.4,0.3,0.1) );
				float mulTime118_g1339 = _TimeParameters.x * 3.6;
				float3 temp_cast_4 = (v.positionOS.xyz.x).xxx;
				float3 worldToObj114_g1339 = mul( GetWorldToObjectMatrix(), float4( temp_cast_4, 1 ) ).xyz;
				float temp_output_119_0_g1339 = ( mulTime118_g1339 + ( 0.2 * worldToObj114_g1339.x ) );
				float3 temp_cast_5 = (0.0).xxx;
				#if defined(_WINDTYPE_GENTLEBREEZE)
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#elif defined(_WINDTYPE_WINDOFF)
				float3 staticSwitch312_g1339 = temp_cast_5;
				#else
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#endif
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( _GlobalWindStrength * staticSwitch312_g1339 );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				o.positionCS = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_AlbedoMap80_g1335 = IN.ase_texcoord.xy;
				float Opacity_Output86_g1335 = ( 1.0 - tex2D( _AlbedoMap, uv_AlbedoMap80_g1335 ).a );
				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = ( Opacity_Output86_g1335 * 1.4 );

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120107


			#pragma vertex vert
			#pragma fragment frag

		    #define SCENEPICKINGPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _WINDTYPE_GENTLEBREEZE _WINDTYPE_WINDOFF


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AlebedoColor;
			float4 _DryLeafColor;
			float _GlobalWindStrength;
			float _SeasonChangeGlobal;
			float _DryLeavesScale;
			float _DryLeavesOffset;
			float _ColorVariation;
			float _BranchMaskR;
			float _VertexLighting;
			float _VertexShadow;
			float _TranslucencyPower;
			float _NormalIntenisty;
			float _SmoothnessIntensity;
			float _AmbientOcclusionIntensity;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AlbedoMap;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult256_g1339 = (float3(0.0 , 0.0 , saturate( v.positionOS.xyz ).z));
				float3 break252_g1339 = v.positionOS.xyz;
				float3 appendResult255_g1339 = (float3(break252_g1339.x , ( break252_g1339.y * 0.15 ) , 0.0));
				float mulTime263_g1339 = _TimeParameters.x * 2.1;
				float3 temp_cast_0 = (v.positionOS.xyz.y).xxx;
				float2 appendResult300_g1339 = (float2(v.positionOS.xyz.x , v.positionOS.xyz.z));
				float3 temp_output_303_0_g1339 = ( cross( temp_cast_0 , float3( appendResult300_g1339 ,  0.0 ) ) * 0.005 );
				float3 appendResult270_g1339 = (float3(0.0 , v.positionOS.xyz.y , 0.0));
				float3 break269_g1339 = v.positionOS.xyz;
				float3 appendResult271_g1339 = (float3(break269_g1339.x , 0.0 , ( break269_g1339.z * 0.15 )));
				float mulTime282_g1339 = _TimeParameters.x * 2.3;
				float3 appendResult293_g1339 = (float3(v.positionOS.xyz.x , 0.0 , 0.0));
				float3 break288_g1339 = v.positionOS.xyz;
				float3 appendResult292_g1339 = (float3(0.0 , ( break288_g1339.y * 0.2 ) , ( break288_g1339.z * 0.4 )));
				float mulTime249_g1339 = _TimeParameters.x * 2.0;
				float3 ase_worldPos = TransformObjectToWorld( (v.positionOS).xyz );
				float3 normalizeResult155_g1339 = normalize( ase_worldPos );
				float mulTime161_g1339 = _TimeParameters.x * 0.25;
				float simplePerlin2D159_g1339 = snoise( ( normalizeResult155_g1339 + mulTime161_g1339 ).xy*0.43 );
				float WindMask_LargeB169_g1339 = ( simplePerlin2D159_g1339 * 1.5 );
				float3 normalizeResult162_g1339 = normalize( ase_worldPos );
				float mulTime167_g1339 = _TimeParameters.x * 0.26;
				float simplePerlin2D166_g1339 = snoise( ( normalizeResult162_g1339 + mulTime167_g1339 ).xy*0.7 );
				float WindMask_LargeC170_g1339 = ( simplePerlin2D166_g1339 * 1.5 );
				float mulTime133_g1339 = _TimeParameters.x * 3.2;
				float3 worldToObj126_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_135_0_g1339 = ( mulTime133_g1339 + ( 0.02 * worldToObj126_g1339.x ) + ( worldToObj126_g1339.y * 0.14 ) + ( worldToObj126_g1339.z * 0.16 ) + float3(0.4,0.3,0.1) );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float mulTime111_g1339 = _TimeParameters.x * 2.3;
				float3 worldToObj103_g1339 = mul( GetWorldToObjectMatrix(), float4( v.positionOS.xyz, 1 ) ).xyz;
				float3 temp_output_106_0_g1339 = ( mulTime111_g1339 + ( 0.2 * worldToObj103_g1339 ) + float3(0.4,0.3,0.1) );
				float mulTime118_g1339 = _TimeParameters.x * 3.6;
				float3 temp_cast_4 = (v.positionOS.xyz.x).xxx;
				float3 worldToObj114_g1339 = mul( GetWorldToObjectMatrix(), float4( temp_cast_4, 1 ) ).xyz;
				float temp_output_119_0_g1339 = ( mulTime118_g1339 + ( 0.2 * worldToObj114_g1339.x ) );
				float3 temp_cast_5 = (0.0).xxx;
				#if defined(_WINDTYPE_GENTLEBREEZE)
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#elif defined(_WINDTYPE_WINDOFF)
				float3 staticSwitch312_g1339 = temp_cast_5;
				#else
				float3 staticSwitch312_g1339 = ( ( ( ( ( ( appendResult256_g1339 + ( appendResult255_g1339 * cos( mulTime263_g1339 ) ) + ( cross( float3(1.2,0.6,1) , ( appendResult255_g1339 * float3(0.7,1,0.8) ) ) * sin( mulTime263_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.08 ) + ( ( ( appendResult270_g1339 + ( appendResult271_g1339 * cos( mulTime282_g1339 ) ) + ( cross( float3(0.9,1,1.2) , ( appendResult271_g1339 * float3(1,1,1) ) ) * sin( mulTime282_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.1 ) + ( ( ( appendResult293_g1339 + ( appendResult292_g1339 * cos( mulTime249_g1339 ) ) + ( cross( float3(1.1,1.3,0.8) , ( appendResult292_g1339 * float3(1.4,0.8,1.1) ) ) * sin( mulTime249_g1339 ) ) ) * temp_output_303_0_g1339 ) * 0.05 ) ) * WindMask_LargeB169_g1339 * saturate( v.positionOS.xyz.y ) ) + ( ( WindMask_LargeC170_g1339 * ( ( ( cos( temp_output_135_0_g1339 ) * sin( temp_output_135_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( cos( temp_output_106_0_g1339 ) * sin( temp_output_106_0_g1339 ) * saturate( ase_objectScale ) ) * 0.2 ) + ( ( sin( temp_output_119_0_g1339 ) * cos( temp_output_119_0_g1339 ) ) * 0.2 ) ) * saturate( v.positionOS.xyz.x ) ) * 0.3 ) );
				#endif
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( _GlobalWindStrength * staticSwitch312_g1339 );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );
				o.positionCS = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_AlbedoMap80_g1335 = IN.ase_texcoord.xy;
				float Opacity_Output86_g1335 = ( 1.0 - tex2D( _AlbedoMap, uv_AlbedoMap80_g1335 ).a );
				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = ( Opacity_Output86_g1335 * 1.4 );

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
						clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphLitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19303
Node;AmplifyShaderEditor.RangedFloatNode;759;-256.827,152.21;Inherit;False;Constant;_AlphaClip;Alpha Clip;0;0;Create;True;0;0;0;False;0;False;1.4;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;763;-378.1451,-55.36316;Inherit;False;(TTFE) Tree Billboard_Shading;0;;1335;0f57c3e4aefb35640bedd1f6e47c6f57;0;0;6;COLOR;162;FLOAT3;168;FLOAT;164;FLOAT;167;FLOAT;163;FLOAT;166
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;760;-87.82703,126.21;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;765;-257.7573,279.2351;Inherit;False;(TTFE) Tree Billboard_Wind System;20;;1339;7781363c3f1900c46819cf845d29a41f;0;0;1;FLOAT3;229
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;749;117.2345,-37.59569;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;750;117.2345,-37.59569;Float;False;True;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;Toby Fredson/The Toby Foliage Engine/(TTFE) Tree Billboard;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;21;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;39;Workflow;1;0;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Forward Only;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;Debug Display;0;0;Clear Coat;0;0;0;10;False;True;True;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;751;117.2345,-37.59569;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;752;117.2345,-37.59569;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;753;117.2345,-37.59569;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;754;117.2345,-37.59569;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;755;117.2345,-37.59569;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;756;117.2345,-37.59569;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;757;117.2345,-37.59569;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;758;117.2345,-37.59569;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
WireConnection;760;0;763;166
WireConnection;760;1;759;0
WireConnection;750;0;763;162
WireConnection;750;1;763;168
WireConnection;750;4;763;167
WireConnection;750;5;763;163
WireConnection;750;7;760;0
WireConnection;750;8;765;229
ASEEND*/
//CHKSM=CD29644CC99328E8ED9EF67EB21E4183143BFC1F