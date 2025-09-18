// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EJERCICIOENTREGA1_Panner"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[NoScaleOffset]_Texture_Packed("Texture_Packed", 2D) = "white" {}
		_Intensity("Intensity", Range( 1 , 20)) = 1
		[Toggle]_ColorFromParticle("ColorFromParticle", Float) = 0
		_BaseColor1("BaseColor1", Color) = (1,1,1)
		_BaseColor2("BaseColor2", Color) = (1,1,1)
		[Header(Channel 1 RGB)][KeywordEnum(Channel_R,Channel_G,Channel_B)] _Texture1("Texture1", Float) = 0
		_X_Tilling_Texture1("X_Tilling_Texture1", Float) = 1
		_Y_Tilling_Texture1("Y_Tilling_Texture1", Float) = 1
		_X_Speed_Texture1("X_Speed_Texture1", Float) = 0
		_Y_Speed_Texture1("Y_Speed_Texture1", Float) = 0
		_OpacityTexture1("Opacity Texture1", Range( 0 , 1)) = 1
		_Texture1_Offset("Texture1_Offset", Range( -1 , 1)) = 0
		_Texture1_Contrast("Texture1_Contrast", Range( 1 , 20)) = 1
		[Header(Channel 2 RGB)][KeywordEnum(Channel_R,Channel_G,Channel_B)] _Texture2("Texture2", Float) = 0
		_X_Tilling_Texture2("X_Tilling_Texture2", Float) = 1
		_Y_Tilling_Texture2("Y_Tilling_Texture2", Float) = 1
		_X_Speed_Texture2("X_Speed_Texture2", Float) = 0
		_Y_Speed_Texture2("Y_Speed_Texture2", Float) = 0
		_OpacityTexture2("Opacity Texture2", Range( 0 , 1)) = 1
		_Texture2_Offset("Texture2_Offset", Range( -1 , 1)) = 0
		_Texture2_Contrast("Texture2_Contrast", Range( 1 , 20)) = 1
		[Space(10)][Header(OPERATION BETWEEN TEXTURES)][Space(10)][KeywordEnum(Multiply_Noises,Add_Noises,Just_Noise1_Active)] _OperationSelector("Operation Selector", Float) = 0
		[NoScaleOffset][Space(10)][Header(DISTORSION NOISE)][Space(10)]_DistorsionNoise("DistorsionNoise", 2D) = "white" {}
		[KeywordEnum(Noise_R,Noise_G,Noise_B)] _RGB_Distorsion_Selector("RGB_Distorsion_Selector", Float) = 0
		_Distorsion_Amount("Distorsion_Amount", Range( 0 , 1)) = 0
		_X_Tilling_DistorsionNoise("X_Tilling_DistorsionNoise", Float) = 1
		_Y_Tilling_DistorsionNoise("Y_Tilling_DistorsionNoise", Float) = 1
		_X_Speed_DistorsionNoise("X_Speed_DistorsionNoise", Float) = 0
		_Y_Speed_DistorsionNoise("Y_Speed_DistorsionNoise", Float) = 0
		[Space(10)][Header(OPACITY)][Space(20)]_OpacityOffset("OpacityOffset", Range( -1 , 1)) = 0
		_GeneralOpacity("GeneralOpacity", Range( 0 , 1)) = 1
		[Space(20)][Header(VERTEX COLOR VISUALIZER)][Space(10)][Toggle(_VERTEXCOLORVISUALIZATOR_ON)] _VertexColorVisualizator("VertexColorVisualizator", Float) = 0


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull Back
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 5.0
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
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			

			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 140011


			

			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			
			#if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			
			#if ASE_SRP_VERSION >=140010
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#endif
		

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _VERTEXCOLORVISUALIZATOR_ON
			#pragma shader_feature_local _OPERATIONSELECTOR_MULTIPLY_NOISES _OPERATIONSELECTOR_ADD_NOISES _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE
			#pragma shader_feature_local _TEXTURE1_CHANNEL_R _TEXTURE1_CHANNEL_G _TEXTURE1_CHANNEL_B
			#pragma shader_feature_local _RGB_DISTORSION_SELECTOR_NOISE_R _RGB_DISTORSION_SELECTOR_NOISE_G _RGB_DISTORSION_SELECTOR_NOISE_B
			#pragma shader_feature_local _TEXTURE2_CHANNEL_R _TEXTURE2_CHANNEL_G _TEXTURE2_CHANNEL_B


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD3;
				#endif
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float3 _BaseColor1;
			float3 _BaseColor2;
			float _Intensity;
			float _OpacityTexture2;
			float _OpacityTexture1;
			float _Y_Speed_Texture2;
			float _X_Speed_Texture2;
			float _Y_Tilling_Texture2;
			float _X_Tilling_Texture2;
			float _Texture2_Contrast;
			float _Texture2_Offset;
			float _Texture1_Offset;
			float _Texture1_Contrast;
			float _Y_Speed_Texture1;
			float _X_Speed_Texture1;
			float _Y_Tilling_Texture1;
			float _X_Tilling_Texture1;
			float _Distorsion_Amount;
			float _Y_Speed_DistorsionNoise;
			float _X_Speed_DistorsionNoise;
			float _Y_Tilling_DistorsionNoise;
			float _X_Tilling_DistorsionNoise;
			float _ColorFromParticle;
			float _OpacityOffset;
			float _GeneralOpacity;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture_Packed;
			sampler2D _DistorsionNoise;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( vertexInput.positionCS.z );
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
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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
				#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
				#endif
				 ) : SV_Target
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

				float2 appendResult51 = (float2(_X_Tilling_DistorsionNoise , _Y_Tilling_DistorsionNoise));
				float2 appendResult53 = (float2(_X_Speed_DistorsionNoise , _Y_Speed_DistorsionNoise));
				float2 panner52 = ( 1.0 * _Time.y * appendResult53 + float2( 0,0 ));
				float2 texCoord50 = IN.ase_texcoord4.xy * appendResult51 + panner52;
				float4 tex2DNode38 = tex2D( _DistorsionNoise, texCoord50 );
				#if defined( _RGB_DISTORSION_SELECTOR_NOISE_R )
				float staticSwitch39 = tex2DNode38.r;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_G )
				float staticSwitch39 = tex2DNode38.g;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_B )
				float staticSwitch39 = tex2DNode38.b;
				#else
				float staticSwitch39 = tex2DNode38.r;
				#endif
				float temp_output_78_0 = ( staticSwitch39 * _Distorsion_Amount );
				float2 appendResult19 = (float2(_X_Tilling_Texture1 , _Y_Tilling_Texture1));
				float2 appendResult14 = (float2(_X_Speed_Texture1 , _Y_Speed_Texture1));
				float2 panner17 = ( 1.0 * _Time.y * appendResult14 + float2( 0,0 ));
				float2 texCoord18 = IN.ase_texcoord4.xy * appendResult19 + panner17;
				float4 tex2DNode10 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord18 ) );
				#if defined( _TEXTURE1_CHANNEL_R )
				float staticSwitch31 = tex2DNode10.r;
				#elif defined( _TEXTURE1_CHANNEL_G )
				float staticSwitch31 = tex2DNode10.g;
				#elif defined( _TEXTURE1_CHANNEL_B )
				float staticSwitch31 = tex2DNode10.b;
				#else
				float staticSwitch31 = tex2DNode10.r;
				#endif
				float temp_output_62_0 = saturate( ( ( staticSwitch31 * _Texture1_Contrast ) + _Texture1_Offset ) );
				float2 appendResult26 = (float2(_X_Tilling_Texture2 , _Y_Tilling_Texture2));
				float2 appendResult30 = (float2(_X_Speed_Texture2 , _Y_Speed_Texture2));
				float2 panner29 = ( 1.0 * _Time.y * appendResult30 + float2( 0,0 ));
				float2 texCoord23 = IN.ase_texcoord4.xy * appendResult26 + panner29;
				float4 tex2DNode22 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord23 ) );
				#if defined( _TEXTURE2_CHANNEL_R )
				float staticSwitch32 = tex2DNode22.r;
				#elif defined( _TEXTURE2_CHANNEL_G )
				float staticSwitch32 = tex2DNode22.g;
				#elif defined( _TEXTURE2_CHANNEL_B )
				float staticSwitch32 = tex2DNode22.b;
				#else
				float staticSwitch32 = tex2DNode22.r;
				#endif
				float temp_output_65_0 = saturate( ( _Texture2_Offset + ( _Texture2_Contrast * staticSwitch32 ) ) );
				#if defined( _OPERATIONSELECTOR_MULTIPLY_NOISES )
				float staticSwitch33 = ( temp_output_62_0 * temp_output_65_0 );
				#elif defined( _OPERATIONSELECTOR_ADD_NOISES )
				float staticSwitch33 = ( temp_output_62_0 + temp_output_65_0 );
				#elif defined( _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE )
				float staticSwitch33 = temp_output_62_0;
				#else
				float staticSwitch33 = ( temp_output_62_0 * temp_output_65_0 );
				#endif
				float temp_output_48_0 = saturate( staticSwitch33 );
				float3 lerpResult46 = lerp( _BaseColor1 , _BaseColor2 , temp_output_48_0);
				#ifdef _VERTEXCOLORVISUALIZATOR_ON
				float4 staticSwitch81 = IN.ase_color;
				#else
				float4 staticSwitch81 = ( _Intensity * (( _ColorFromParticle )?( ( temp_output_48_0 * IN.ase_color ) ):( float4( lerpResult46 , 0.0 ) )) );
				#endif
				
				float temp_output_91_0 = ( temp_output_62_0 * _OpacityTexture1 );
				float temp_output_92_0 = ( temp_output_65_0 * _OpacityTexture2 );
				#if defined( _OPERATIONSELECTOR_MULTIPLY_NOISES )
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_ADD_NOISES )
				float staticSwitch94 = ( temp_output_91_0 + temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE )
				float staticSwitch94 = temp_output_91_0;
				#else
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#endif
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = staticSwitch81.rgb;
				float Alpha = ( saturate( ( saturate( staticSwitch94 ) + _OpacityOffset ) ) * IN.ase_color.a * _GeneralOpacity );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.positionCS, Color);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.positionCS );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return half4( Color, Alpha );
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

			

			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 140011


			

			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#pragma shader_feature_local _OPERATIONSELECTOR_MULTIPLY_NOISES _OPERATIONSELECTOR_ADD_NOISES _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE
			#pragma shader_feature_local _TEXTURE1_CHANNEL_R _TEXTURE1_CHANNEL_G _TEXTURE1_CHANNEL_B
			#pragma shader_feature_local _RGB_DISTORSION_SELECTOR_NOISE_R _RGB_DISTORSION_SELECTOR_NOISE_G _RGB_DISTORSION_SELECTOR_NOISE_B
			#pragma shader_feature_local _TEXTURE2_CHANNEL_R _TEXTURE2_CHANNEL_G _TEXTURE2_CHANNEL_B


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float3 _BaseColor1;
			float3 _BaseColor2;
			float _Intensity;
			float _OpacityTexture2;
			float _OpacityTexture1;
			float _Y_Speed_Texture2;
			float _X_Speed_Texture2;
			float _Y_Tilling_Texture2;
			float _X_Tilling_Texture2;
			float _Texture2_Contrast;
			float _Texture2_Offset;
			float _Texture1_Offset;
			float _Texture1_Contrast;
			float _Y_Speed_Texture1;
			float _X_Speed_Texture1;
			float _Y_Tilling_Texture1;
			float _X_Tilling_Texture1;
			float _Distorsion_Amount;
			float _Y_Speed_DistorsionNoise;
			float _X_Speed_DistorsionNoise;
			float _Y_Tilling_DistorsionNoise;
			float _X_Tilling_DistorsionNoise;
			float _ColorFromParticle;
			float _OpacityOffset;
			float _GeneralOpacity;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture_Packed;
			sampler2D _DistorsionNoise;


			
			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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

				float3 normalWS = TransformObjectToWorldDir( v.normalOS );

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

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float2 appendResult51 = (float2(_X_Tilling_DistorsionNoise , _Y_Tilling_DistorsionNoise));
				float2 appendResult53 = (float2(_X_Speed_DistorsionNoise , _Y_Speed_DistorsionNoise));
				float2 panner52 = ( 1.0 * _Time.y * appendResult53 + float2( 0,0 ));
				float2 texCoord50 = IN.ase_texcoord2.xy * appendResult51 + panner52;
				float4 tex2DNode38 = tex2D( _DistorsionNoise, texCoord50 );
				#if defined( _RGB_DISTORSION_SELECTOR_NOISE_R )
				float staticSwitch39 = tex2DNode38.r;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_G )
				float staticSwitch39 = tex2DNode38.g;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_B )
				float staticSwitch39 = tex2DNode38.b;
				#else
				float staticSwitch39 = tex2DNode38.r;
				#endif
				float temp_output_78_0 = ( staticSwitch39 * _Distorsion_Amount );
				float2 appendResult19 = (float2(_X_Tilling_Texture1 , _Y_Tilling_Texture1));
				float2 appendResult14 = (float2(_X_Speed_Texture1 , _Y_Speed_Texture1));
				float2 panner17 = ( 1.0 * _Time.y * appendResult14 + float2( 0,0 ));
				float2 texCoord18 = IN.ase_texcoord2.xy * appendResult19 + panner17;
				float4 tex2DNode10 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord18 ) );
				#if defined( _TEXTURE1_CHANNEL_R )
				float staticSwitch31 = tex2DNode10.r;
				#elif defined( _TEXTURE1_CHANNEL_G )
				float staticSwitch31 = tex2DNode10.g;
				#elif defined( _TEXTURE1_CHANNEL_B )
				float staticSwitch31 = tex2DNode10.b;
				#else
				float staticSwitch31 = tex2DNode10.r;
				#endif
				float temp_output_62_0 = saturate( ( ( staticSwitch31 * _Texture1_Contrast ) + _Texture1_Offset ) );
				float temp_output_91_0 = ( temp_output_62_0 * _OpacityTexture1 );
				float2 appendResult26 = (float2(_X_Tilling_Texture2 , _Y_Tilling_Texture2));
				float2 appendResult30 = (float2(_X_Speed_Texture2 , _Y_Speed_Texture2));
				float2 panner29 = ( 1.0 * _Time.y * appendResult30 + float2( 0,0 ));
				float2 texCoord23 = IN.ase_texcoord2.xy * appendResult26 + panner29;
				float4 tex2DNode22 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord23 ) );
				#if defined( _TEXTURE2_CHANNEL_R )
				float staticSwitch32 = tex2DNode22.r;
				#elif defined( _TEXTURE2_CHANNEL_G )
				float staticSwitch32 = tex2DNode22.g;
				#elif defined( _TEXTURE2_CHANNEL_B )
				float staticSwitch32 = tex2DNode22.b;
				#else
				float staticSwitch32 = tex2DNode22.r;
				#endif
				float temp_output_65_0 = saturate( ( _Texture2_Offset + ( _Texture2_Contrast * staticSwitch32 ) ) );
				float temp_output_92_0 = ( temp_output_65_0 * _OpacityTexture2 );
				#if defined( _OPERATIONSELECTOR_MULTIPLY_NOISES )
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_ADD_NOISES )
				float staticSwitch94 = ( temp_output_91_0 + temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE )
				float staticSwitch94 = temp_output_91_0;
				#else
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#endif
				

				float Alpha = ( saturate( ( saturate( staticSwitch94 ) + _OpacityOffset ) ) * IN.ase_color.a * _GeneralOpacity );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.positionCS );
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
			ColorMask R
			AlphaToMask Off

			HLSLPROGRAM

			

			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 140011


			

			#pragma vertex vert
			#pragma fragment frag

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#pragma shader_feature_local _OPERATIONSELECTOR_MULTIPLY_NOISES _OPERATIONSELECTOR_ADD_NOISES _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE
			#pragma shader_feature_local _TEXTURE1_CHANNEL_R _TEXTURE1_CHANNEL_G _TEXTURE1_CHANNEL_B
			#pragma shader_feature_local _RGB_DISTORSION_SELECTOR_NOISE_R _RGB_DISTORSION_SELECTOR_NOISE_G _RGB_DISTORSION_SELECTOR_NOISE_B
			#pragma shader_feature_local _TEXTURE2_CHANNEL_R _TEXTURE2_CHANNEL_G _TEXTURE2_CHANNEL_B


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float3 _BaseColor1;
			float3 _BaseColor2;
			float _Intensity;
			float _OpacityTexture2;
			float _OpacityTexture1;
			float _Y_Speed_Texture2;
			float _X_Speed_Texture2;
			float _Y_Tilling_Texture2;
			float _X_Tilling_Texture2;
			float _Texture2_Contrast;
			float _Texture2_Offset;
			float _Texture1_Offset;
			float _Texture1_Contrast;
			float _Y_Speed_Texture1;
			float _X_Speed_Texture1;
			float _Y_Tilling_Texture1;
			float _X_Tilling_Texture1;
			float _Distorsion_Amount;
			float _Y_Speed_DistorsionNoise;
			float _X_Speed_DistorsionNoise;
			float _Y_Tilling_DistorsionNoise;
			float _X_Tilling_DistorsionNoise;
			float _ColorFromParticle;
			float _OpacityOffset;
			float _GeneralOpacity;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture_Packed;
			sampler2D _DistorsionNoise;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 appendResult51 = (float2(_X_Tilling_DistorsionNoise , _Y_Tilling_DistorsionNoise));
				float2 appendResult53 = (float2(_X_Speed_DistorsionNoise , _Y_Speed_DistorsionNoise));
				float2 panner52 = ( 1.0 * _Time.y * appendResult53 + float2( 0,0 ));
				float2 texCoord50 = IN.ase_texcoord3.xy * appendResult51 + panner52;
				float4 tex2DNode38 = tex2D( _DistorsionNoise, texCoord50 );
				#if defined( _RGB_DISTORSION_SELECTOR_NOISE_R )
				float staticSwitch39 = tex2DNode38.r;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_G )
				float staticSwitch39 = tex2DNode38.g;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_B )
				float staticSwitch39 = tex2DNode38.b;
				#else
				float staticSwitch39 = tex2DNode38.r;
				#endif
				float temp_output_78_0 = ( staticSwitch39 * _Distorsion_Amount );
				float2 appendResult19 = (float2(_X_Tilling_Texture1 , _Y_Tilling_Texture1));
				float2 appendResult14 = (float2(_X_Speed_Texture1 , _Y_Speed_Texture1));
				float2 panner17 = ( 1.0 * _Time.y * appendResult14 + float2( 0,0 ));
				float2 texCoord18 = IN.ase_texcoord3.xy * appendResult19 + panner17;
				float4 tex2DNode10 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord18 ) );
				#if defined( _TEXTURE1_CHANNEL_R )
				float staticSwitch31 = tex2DNode10.r;
				#elif defined( _TEXTURE1_CHANNEL_G )
				float staticSwitch31 = tex2DNode10.g;
				#elif defined( _TEXTURE1_CHANNEL_B )
				float staticSwitch31 = tex2DNode10.b;
				#else
				float staticSwitch31 = tex2DNode10.r;
				#endif
				float temp_output_62_0 = saturate( ( ( staticSwitch31 * _Texture1_Contrast ) + _Texture1_Offset ) );
				float temp_output_91_0 = ( temp_output_62_0 * _OpacityTexture1 );
				float2 appendResult26 = (float2(_X_Tilling_Texture2 , _Y_Tilling_Texture2));
				float2 appendResult30 = (float2(_X_Speed_Texture2 , _Y_Speed_Texture2));
				float2 panner29 = ( 1.0 * _Time.y * appendResult30 + float2( 0,0 ));
				float2 texCoord23 = IN.ase_texcoord3.xy * appendResult26 + panner29;
				float4 tex2DNode22 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord23 ) );
				#if defined( _TEXTURE2_CHANNEL_R )
				float staticSwitch32 = tex2DNode22.r;
				#elif defined( _TEXTURE2_CHANNEL_G )
				float staticSwitch32 = tex2DNode22.g;
				#elif defined( _TEXTURE2_CHANNEL_B )
				float staticSwitch32 = tex2DNode22.b;
				#else
				float staticSwitch32 = tex2DNode22.r;
				#endif
				float temp_output_65_0 = saturate( ( _Texture2_Offset + ( _Texture2_Contrast * staticSwitch32 ) ) );
				float temp_output_92_0 = ( temp_output_65_0 * _OpacityTexture2 );
				#if defined( _OPERATIONSELECTOR_MULTIPLY_NOISES )
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_ADD_NOISES )
				float staticSwitch94 = ( temp_output_91_0 + temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE )
				float staticSwitch94 = temp_output_91_0;
				#else
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#endif
				

				float Alpha = ( saturate( ( saturate( staticSwitch94 ) + _OpacityOffset ) ) * IN.ase_color.a * _GeneralOpacity );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.positionCS );
				#endif
				return 0;
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

			

			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 140011


			

			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			
			#if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			
			#if ASE_SRP_VERSION >=140010
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#endif
		

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#pragma shader_feature_local _OPERATIONSELECTOR_MULTIPLY_NOISES _OPERATIONSELECTOR_ADD_NOISES _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE
			#pragma shader_feature_local _TEXTURE1_CHANNEL_R _TEXTURE1_CHANNEL_G _TEXTURE1_CHANNEL_B
			#pragma shader_feature_local _RGB_DISTORSION_SELECTOR_NOISE_R _RGB_DISTORSION_SELECTOR_NOISE_G _RGB_DISTORSION_SELECTOR_NOISE_B
			#pragma shader_feature_local _TEXTURE2_CHANNEL_R _TEXTURE2_CHANNEL_G _TEXTURE2_CHANNEL_B


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float3 _BaseColor1;
			float3 _BaseColor2;
			float _Intensity;
			float _OpacityTexture2;
			float _OpacityTexture1;
			float _Y_Speed_Texture2;
			float _X_Speed_Texture2;
			float _Y_Tilling_Texture2;
			float _X_Tilling_Texture2;
			float _Texture2_Contrast;
			float _Texture2_Offset;
			float _Texture1_Offset;
			float _Texture1_Contrast;
			float _Y_Speed_Texture1;
			float _X_Speed_Texture1;
			float _Y_Tilling_Texture1;
			float _X_Tilling_Texture1;
			float _Distorsion_Amount;
			float _Y_Speed_DistorsionNoise;
			float _X_Speed_DistorsionNoise;
			float _Y_Tilling_DistorsionNoise;
			float _X_Tilling_DistorsionNoise;
			float _ColorFromParticle;
			float _OpacityOffset;
			float _GeneralOpacity;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture_Packed;
			sampler2D _DistorsionNoise;


			
			int _ObjectId;
			int _PassValue;

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

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float2 appendResult51 = (float2(_X_Tilling_DistorsionNoise , _Y_Tilling_DistorsionNoise));
				float2 appendResult53 = (float2(_X_Speed_DistorsionNoise , _Y_Speed_DistorsionNoise));
				float2 panner52 = ( 1.0 * _Time.y * appendResult53 + float2( 0,0 ));
				float2 texCoord50 = IN.ase_texcoord.xy * appendResult51 + panner52;
				float4 tex2DNode38 = tex2D( _DistorsionNoise, texCoord50 );
				#if defined( _RGB_DISTORSION_SELECTOR_NOISE_R )
				float staticSwitch39 = tex2DNode38.r;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_G )
				float staticSwitch39 = tex2DNode38.g;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_B )
				float staticSwitch39 = tex2DNode38.b;
				#else
				float staticSwitch39 = tex2DNode38.r;
				#endif
				float temp_output_78_0 = ( staticSwitch39 * _Distorsion_Amount );
				float2 appendResult19 = (float2(_X_Tilling_Texture1 , _Y_Tilling_Texture1));
				float2 appendResult14 = (float2(_X_Speed_Texture1 , _Y_Speed_Texture1));
				float2 panner17 = ( 1.0 * _Time.y * appendResult14 + float2( 0,0 ));
				float2 texCoord18 = IN.ase_texcoord.xy * appendResult19 + panner17;
				float4 tex2DNode10 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord18 ) );
				#if defined( _TEXTURE1_CHANNEL_R )
				float staticSwitch31 = tex2DNode10.r;
				#elif defined( _TEXTURE1_CHANNEL_G )
				float staticSwitch31 = tex2DNode10.g;
				#elif defined( _TEXTURE1_CHANNEL_B )
				float staticSwitch31 = tex2DNode10.b;
				#else
				float staticSwitch31 = tex2DNode10.r;
				#endif
				float temp_output_62_0 = saturate( ( ( staticSwitch31 * _Texture1_Contrast ) + _Texture1_Offset ) );
				float temp_output_91_0 = ( temp_output_62_0 * _OpacityTexture1 );
				float2 appendResult26 = (float2(_X_Tilling_Texture2 , _Y_Tilling_Texture2));
				float2 appendResult30 = (float2(_X_Speed_Texture2 , _Y_Speed_Texture2));
				float2 panner29 = ( 1.0 * _Time.y * appendResult30 + float2( 0,0 ));
				float2 texCoord23 = IN.ase_texcoord.xy * appendResult26 + panner29;
				float4 tex2DNode22 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord23 ) );
				#if defined( _TEXTURE2_CHANNEL_R )
				float staticSwitch32 = tex2DNode22.r;
				#elif defined( _TEXTURE2_CHANNEL_G )
				float staticSwitch32 = tex2DNode22.g;
				#elif defined( _TEXTURE2_CHANNEL_B )
				float staticSwitch32 = tex2DNode22.b;
				#else
				float staticSwitch32 = tex2DNode22.r;
				#endif
				float temp_output_65_0 = saturate( ( _Texture2_Offset + ( _Texture2_Contrast * staticSwitch32 ) ) );
				float temp_output_92_0 = ( temp_output_65_0 * _OpacityTexture2 );
				#if defined( _OPERATIONSELECTOR_MULTIPLY_NOISES )
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_ADD_NOISES )
				float staticSwitch94 = ( temp_output_91_0 + temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE )
				float staticSwitch94 = temp_output_91_0;
				#else
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#endif
				

				surfaceDescription.Alpha = ( saturate( ( saturate( staticSwitch94 ) + _OpacityOffset ) ) * IN.ase_color.a * _GeneralOpacity );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
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

			

			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 140011


			

			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT

			#define SHADERPASS SHADERPASS_DEPTHONLY

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			
			#if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			
			#if ASE_SRP_VERSION >=140010
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#endif
		

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#pragma shader_feature_local _OPERATIONSELECTOR_MULTIPLY_NOISES _OPERATIONSELECTOR_ADD_NOISES _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE
			#pragma shader_feature_local _TEXTURE1_CHANNEL_R _TEXTURE1_CHANNEL_G _TEXTURE1_CHANNEL_B
			#pragma shader_feature_local _RGB_DISTORSION_SELECTOR_NOISE_R _RGB_DISTORSION_SELECTOR_NOISE_G _RGB_DISTORSION_SELECTOR_NOISE_B
			#pragma shader_feature_local _TEXTURE2_CHANNEL_R _TEXTURE2_CHANNEL_G _TEXTURE2_CHANNEL_B


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float3 _BaseColor1;
			float3 _BaseColor2;
			float _Intensity;
			float _OpacityTexture2;
			float _OpacityTexture1;
			float _Y_Speed_Texture2;
			float _X_Speed_Texture2;
			float _Y_Tilling_Texture2;
			float _X_Tilling_Texture2;
			float _Texture2_Contrast;
			float _Texture2_Offset;
			float _Texture1_Offset;
			float _Texture1_Contrast;
			float _Y_Speed_Texture1;
			float _X_Speed_Texture1;
			float _Y_Tilling_Texture1;
			float _X_Tilling_Texture1;
			float _Distorsion_Amount;
			float _Y_Speed_DistorsionNoise;
			float _X_Speed_DistorsionNoise;
			float _Y_Tilling_DistorsionNoise;
			float _X_Tilling_DistorsionNoise;
			float _ColorFromParticle;
			float _OpacityOffset;
			float _GeneralOpacity;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture_Packed;
			sampler2D _DistorsionNoise;


			
			float4 _SelectionID;

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

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float2 appendResult51 = (float2(_X_Tilling_DistorsionNoise , _Y_Tilling_DistorsionNoise));
				float2 appendResult53 = (float2(_X_Speed_DistorsionNoise , _Y_Speed_DistorsionNoise));
				float2 panner52 = ( 1.0 * _Time.y * appendResult53 + float2( 0,0 ));
				float2 texCoord50 = IN.ase_texcoord.xy * appendResult51 + panner52;
				float4 tex2DNode38 = tex2D( _DistorsionNoise, texCoord50 );
				#if defined( _RGB_DISTORSION_SELECTOR_NOISE_R )
				float staticSwitch39 = tex2DNode38.r;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_G )
				float staticSwitch39 = tex2DNode38.g;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_B )
				float staticSwitch39 = tex2DNode38.b;
				#else
				float staticSwitch39 = tex2DNode38.r;
				#endif
				float temp_output_78_0 = ( staticSwitch39 * _Distorsion_Amount );
				float2 appendResult19 = (float2(_X_Tilling_Texture1 , _Y_Tilling_Texture1));
				float2 appendResult14 = (float2(_X_Speed_Texture1 , _Y_Speed_Texture1));
				float2 panner17 = ( 1.0 * _Time.y * appendResult14 + float2( 0,0 ));
				float2 texCoord18 = IN.ase_texcoord.xy * appendResult19 + panner17;
				float4 tex2DNode10 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord18 ) );
				#if defined( _TEXTURE1_CHANNEL_R )
				float staticSwitch31 = tex2DNode10.r;
				#elif defined( _TEXTURE1_CHANNEL_G )
				float staticSwitch31 = tex2DNode10.g;
				#elif defined( _TEXTURE1_CHANNEL_B )
				float staticSwitch31 = tex2DNode10.b;
				#else
				float staticSwitch31 = tex2DNode10.r;
				#endif
				float temp_output_62_0 = saturate( ( ( staticSwitch31 * _Texture1_Contrast ) + _Texture1_Offset ) );
				float temp_output_91_0 = ( temp_output_62_0 * _OpacityTexture1 );
				float2 appendResult26 = (float2(_X_Tilling_Texture2 , _Y_Tilling_Texture2));
				float2 appendResult30 = (float2(_X_Speed_Texture2 , _Y_Speed_Texture2));
				float2 panner29 = ( 1.0 * _Time.y * appendResult30 + float2( 0,0 ));
				float2 texCoord23 = IN.ase_texcoord.xy * appendResult26 + panner29;
				float4 tex2DNode22 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord23 ) );
				#if defined( _TEXTURE2_CHANNEL_R )
				float staticSwitch32 = tex2DNode22.r;
				#elif defined( _TEXTURE2_CHANNEL_G )
				float staticSwitch32 = tex2DNode22.g;
				#elif defined( _TEXTURE2_CHANNEL_B )
				float staticSwitch32 = tex2DNode22.b;
				#else
				float staticSwitch32 = tex2DNode22.r;
				#endif
				float temp_output_65_0 = saturate( ( _Texture2_Offset + ( _Texture2_Contrast * staticSwitch32 ) ) );
				float temp_output_92_0 = ( temp_output_65_0 * _OpacityTexture2 );
				#if defined( _OPERATIONSELECTOR_MULTIPLY_NOISES )
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_ADD_NOISES )
				float staticSwitch94 = ( temp_output_91_0 + temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE )
				float staticSwitch94 = temp_output_91_0;
				#else
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#endif
				

				surfaceDescription.Alpha = ( saturate( ( saturate( staticSwitch94 ) + _OpacityOffset ) ) * IN.ase_color.a * _GeneralOpacity );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			

        	#pragma multi_compile_instancing
        	#pragma multi_compile _ LOD_FADE_CROSSFADE
        	#define ASE_FOG 1
        	#define _SURFACE_TYPE_TRANSPARENT 1
        	#define ASE_SRP_VERSION 140011


			

        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			

			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			
			#if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			
			#if ASE_SRP_VERSION >=140010
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#endif
		

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

            #if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#pragma shader_feature_local _OPERATIONSELECTOR_MULTIPLY_NOISES _OPERATIONSELECTOR_ADD_NOISES _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE
			#pragma shader_feature_local _TEXTURE1_CHANNEL_R _TEXTURE1_CHANNEL_G _TEXTURE1_CHANNEL_B
			#pragma shader_feature_local _RGB_DISTORSION_SELECTOR_NOISE_R _RGB_DISTORSION_SELECTOR_NOISE_G _RGB_DISTORSION_SELECTOR_NOISE_B
			#pragma shader_feature_local _TEXTURE2_CHANNEL_R _TEXTURE2_CHANNEL_G _TEXTURE2_CHANNEL_B


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float3 _BaseColor1;
			float3 _BaseColor2;
			float _Intensity;
			float _OpacityTexture2;
			float _OpacityTexture1;
			float _Y_Speed_Texture2;
			float _X_Speed_Texture2;
			float _Y_Tilling_Texture2;
			float _X_Tilling_Texture2;
			float _Texture2_Contrast;
			float _Texture2_Offset;
			float _Texture1_Offset;
			float _Texture1_Contrast;
			float _Y_Speed_Texture1;
			float _X_Speed_Texture1;
			float _Y_Tilling_Texture1;
			float _X_Tilling_Texture1;
			float _Distorsion_Amount;
			float _Y_Speed_DistorsionNoise;
			float _X_Speed_DistorsionNoise;
			float _Y_Tilling_DistorsionNoise;
			float _X_Tilling_DistorsionNoise;
			float _ColorFromParticle;
			float _OpacityOffset;
			float _GeneralOpacity;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Texture_Packed;
			sampler2D _DistorsionNoise;


			
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

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );

				o.positionCS = vertexInput.positionCS;
				o.clipPosV = vertexInput.positionCS;
				o.normalWS = TransformObjectToWorldNormal( v.normalOS );
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

			void frag( VertexOutput IN
				, out half4 outNormalWS : SV_Target0
			#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
			#endif
				 )
			{
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 appendResult51 = (float2(_X_Tilling_DistorsionNoise , _Y_Tilling_DistorsionNoise));
				float2 appendResult53 = (float2(_X_Speed_DistorsionNoise , _Y_Speed_DistorsionNoise));
				float2 panner52 = ( 1.0 * _Time.y * appendResult53 + float2( 0,0 ));
				float2 texCoord50 = IN.ase_texcoord2.xy * appendResult51 + panner52;
				float4 tex2DNode38 = tex2D( _DistorsionNoise, texCoord50 );
				#if defined( _RGB_DISTORSION_SELECTOR_NOISE_R )
				float staticSwitch39 = tex2DNode38.r;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_G )
				float staticSwitch39 = tex2DNode38.g;
				#elif defined( _RGB_DISTORSION_SELECTOR_NOISE_B )
				float staticSwitch39 = tex2DNode38.b;
				#else
				float staticSwitch39 = tex2DNode38.r;
				#endif
				float temp_output_78_0 = ( staticSwitch39 * _Distorsion_Amount );
				float2 appendResult19 = (float2(_X_Tilling_Texture1 , _Y_Tilling_Texture1));
				float2 appendResult14 = (float2(_X_Speed_Texture1 , _Y_Speed_Texture1));
				float2 panner17 = ( 1.0 * _Time.y * appendResult14 + float2( 0,0 ));
				float2 texCoord18 = IN.ase_texcoord2.xy * appendResult19 + panner17;
				float4 tex2DNode10 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord18 ) );
				#if defined( _TEXTURE1_CHANNEL_R )
				float staticSwitch31 = tex2DNode10.r;
				#elif defined( _TEXTURE1_CHANNEL_G )
				float staticSwitch31 = tex2DNode10.g;
				#elif defined( _TEXTURE1_CHANNEL_B )
				float staticSwitch31 = tex2DNode10.b;
				#else
				float staticSwitch31 = tex2DNode10.r;
				#endif
				float temp_output_62_0 = saturate( ( ( staticSwitch31 * _Texture1_Contrast ) + _Texture1_Offset ) );
				float temp_output_91_0 = ( temp_output_62_0 * _OpacityTexture1 );
				float2 appendResult26 = (float2(_X_Tilling_Texture2 , _Y_Tilling_Texture2));
				float2 appendResult30 = (float2(_X_Speed_Texture2 , _Y_Speed_Texture2));
				float2 panner29 = ( 1.0 * _Time.y * appendResult30 + float2( 0,0 ));
				float2 texCoord23 = IN.ase_texcoord2.xy * appendResult26 + panner29;
				float4 tex2DNode22 = tex2D( _Texture_Packed, ( temp_output_78_0 + texCoord23 ) );
				#if defined( _TEXTURE2_CHANNEL_R )
				float staticSwitch32 = tex2DNode22.r;
				#elif defined( _TEXTURE2_CHANNEL_G )
				float staticSwitch32 = tex2DNode22.g;
				#elif defined( _TEXTURE2_CHANNEL_B )
				float staticSwitch32 = tex2DNode22.b;
				#else
				float staticSwitch32 = tex2DNode22.r;
				#endif
				float temp_output_65_0 = saturate( ( _Texture2_Offset + ( _Texture2_Contrast * staticSwitch32 ) ) );
				float temp_output_92_0 = ( temp_output_65_0 * _OpacityTexture2 );
				#if defined( _OPERATIONSELECTOR_MULTIPLY_NOISES )
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_ADD_NOISES )
				float staticSwitch94 = ( temp_output_91_0 + temp_output_92_0 );
				#elif defined( _OPERATIONSELECTOR_JUST_NOISE1_ACTIVE )
				float staticSwitch94 = temp_output_91_0;
				#else
				float staticSwitch94 = ( temp_output_91_0 * temp_output_92_0 );
				#endif
				

				float Alpha = ( saturate( ( saturate( staticSwitch94 ) + _OpacityOffset ) ) * IN.ase_color.a * _GeneralOpacity );
				float AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.positionCS );
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float3 normalWS = normalize(IN.normalWS);
					float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					float3 normalWS = IN.normalWS;
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}

			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.CommentaryNode;68;-2562,-850;Inherit;False;1460;466.8;Distorion;11;51;54;38;39;50;52;53;55;56;57;37;;1,0,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2512,-576;Inherit;False;Property;_X_Speed_DistorsionNoise;X_Speed_DistorsionNoise;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2512,-496;Inherit;False;Property;_Y_Speed_DistorsionNoise;Y_Speed_DistorsionNoise;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2336,-800;Inherit;False;Property;_X_Tilling_DistorsionNoise;X_Tilling_DistorsionNoise;25;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-2304,-576;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2336,-720;Inherit;False;Property;_Y_Tilling_DistorsionNoise;Y_Tilling_DistorsionNoise;26;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;70;-2096,-336;Inherit;False;2084;546.8;Noise 1;25;61;2;3;4;5;6;7;8;9;31;10;18;19;17;14;20;21;15;16;59;58;62;60;0;80;;0.4249977,0.9924528,0.3351868,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;51;-2144,-784;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;52;-2160,-608;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;69;-2098,414;Inherit;False;2100;498.8;Noise 2;16;23;26;29;30;22;27;28;24;25;32;63;64;65;66;67;79;;0.3150943,0.7565591,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2032,-64;Inherit;False;Property;_X_Speed_Texture1;X_Speed_Texture1;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2032,16;Inherit;False;Property;_Y_Speed_Texture1;Y_Speed_Texture1;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-1968,-656;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-2048,720;Inherit;False;Property;_X_Speed_Texture2;X_Speed_Texture2;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2048,800;Inherit;False;Property;_Y_Speed_Texture2;Y_Speed_Texture2;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-1824,-64;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1856,-288;Inherit;False;Property;_X_Tilling_Texture1;X_Tilling_Texture1;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1856,-208;Inherit;False;Property;_Y_Tilling_Texture1;Y_Tilling_Texture1;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;38;-1728,-672;Inherit;True;Property;_DistorsionNoise;DistorsionNoise;22;1;[NoScaleOffset];Create;True;0;0;0;False;3;Space(10);Header(DISTORSION NOISE);Space(10);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.DynamicAppendNode;30;-1840,720;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1872,496;Inherit;False;Property;_X_Tilling_Texture2;X_Tilling_Texture2;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1872,576;Inherit;False;Property;_Y_Tilling_Texture2;Y_Tilling_Texture2;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-1664,-272;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;17;-1680,-96;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;39;-1440,-624;Inherit;False;Property;_RGB_Distorsion_Selector;RGB_Distorsion_Selector;23;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;Noise_R;Noise_G;Noise_B;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-1680,512;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;29;-1696,688;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1376,-480;Inherit;False;Property;_Distorsion_Amount;Distorsion_Amount;24;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-1488,-144;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-1504,640;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1056,-560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-1168,608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-1216,-160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;22;-1008,624;Inherit;True;Property;_Texture2;Texture2;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;10;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;10;-1024,-160;Inherit;True;Property;_Texture_Packed;Texture_Packed;0;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.StaticSwitch;32;-720,672;Inherit;False;Property;_Texture2;Texture2;13;0;Create;True;0;0;0;False;1;Header(Channel 2 RGB);False;0;0;0;True;;KeywordEnum;3;Channel_R;Channel_G;Channel_B;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;31;-720,-96;Inherit;False;Property;_Texture1;Texture1;5;0;Create;True;0;0;0;False;1;Header(Channel 1 RGB);False;0;0;0;True;;KeywordEnum;3;Channel_R;Channel_G;Channel_B;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-688,32;Inherit;False;Property;_Texture1_Contrast;Texture1_Contrast;12;0;Create;True;0;0;0;False;0;False;1;0;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-736,560;Inherit;False;Property;_Texture2_Contrast;Texture2_Contrast;20;0;Create;True;0;0;0;False;0;False;1;0;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-464,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-688,112;Inherit;False;Property;_Texture1_Offset;Texture1_Offset;11;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-464,624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-752,480;Inherit;False;Property;_Texture2_Offset;Texture2_Offset;19;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-304,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-304,576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;62;-176,-112;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;65;-176,576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;112,496;Inherit;False;Property;_OpacityTexture2;Opacity Texture2;18;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;112,304;Inherit;False;Property;_OpacityTexture1;Opacity Texture1;10;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;128,576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;128,368;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;384,496;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;400,368;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;94;528,464;Inherit;False;Property;_OperationSelector1;Operation Selector;21;0;Create;True;0;0;0;False;3;Space(10);Header(OPERATION BETWEEN TEXTURES);Space(10);False;0;0;0;True;;KeywordEnum;3;Multiply_Noises;Add_Noises;Just_Noise1_Active;Reference;33;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;688,624;Inherit;False;Property;_OpacityOffset;OpacityOffset;29;0;Create;True;0;0;0;False;3;Space(10);Header(OPACITY);Space(20);False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;90;832,528;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;992,544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;1552,944;Inherit;False;Property;_GeneralOpacity;GeneralOpacity;30;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;82;1360,608;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;75;1120,560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;96,192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;96,96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;43;1008,96;Inherit;False;Property;_ColorFromParticle;ColorFromParticle;2;0;Create;True;0;0;0;False;0;False;0;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;45;544,-320;Inherit;False;Property;_BaseColor1;BaseColor1;3;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;False;0;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;47;528,-176;Inherit;False;Property;_BaseColor2;BaseColor2;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;False;0;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.StaticSwitch;81;1584,80;Inherit;False;Property;_VertexColorVisualizator;VertexColorVisualizator;31;0;Create;True;0;0;0;False;3;Space(20);Header(VERTEX COLOR VISUALIZER);Space(10);False;0;0;0;True;;Toggle;2;;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;1344,80;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;1856,560;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;46;800,32;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;800,160;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;44;816,256;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;48;512,144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;33;224,144;Inherit;False;Property;_OperationSelector;Operation Selector;21;0;Create;True;0;0;0;False;3;Space(10);Header(OPERATION BETWEEN TEXTURES);Space(10);False;0;0;0;True;;KeywordEnum;3;Multiply_Noises;Add_Noises;Just_Noise1_Active;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;1008,16;Inherit;False;Property;_Intensity;Intensity;1;0;Create;True;0;0;0;False;0;False;1;1;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;True;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-640,-16;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;2048,192;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;EJERCICIOENTREGA1_Panner;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;7;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;22;Surface;1;638640844023170636;  Blend;0;0;Two Sided;1;638646058704338937;Forward Only;0;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;True;True;False;False;True;True;True;False;False;;False;0
WireConnection;53;0;56;0
WireConnection;53;1;57;0
WireConnection;51;0;54;0
WireConnection;51;1;55;0
WireConnection;52;2;53;0
WireConnection;50;0;51;0
WireConnection;50;1;52;0
WireConnection;14;0;15;0
WireConnection;14;1;16;0
WireConnection;38;1;50;0
WireConnection;30;0;24;0
WireConnection;30;1;25;0
WireConnection;19;0;20;0
WireConnection;19;1;21;0
WireConnection;17;2;14;0
WireConnection;39;1;38;1
WireConnection;39;0;38;2
WireConnection;39;2;38;3
WireConnection;26;0;27;0
WireConnection;26;1;28;0
WireConnection;29;2;30;0
WireConnection;18;0;19;0
WireConnection;18;1;17;0
WireConnection;23;0;26;0
WireConnection;23;1;29;0
WireConnection;78;0;39;0
WireConnection;78;1;37;0
WireConnection;79;0;78;0
WireConnection;79;1;23;0
WireConnection;80;0;78;0
WireConnection;80;1;18;0
WireConnection;22;1;79;0
WireConnection;10;1;80;0
WireConnection;32;1;22;1
WireConnection;32;0;22;2
WireConnection;32;2;22;3
WireConnection;31;1;10;1
WireConnection;31;0;10;2
WireConnection;31;2;10;3
WireConnection;58;0;31;0
WireConnection;58;1;61;0
WireConnection;64;0;67;0
WireConnection;64;1;32;0
WireConnection;59;0;58;0
WireConnection;59;1;60;0
WireConnection;63;0;66;0
WireConnection;63;1;64;0
WireConnection;62;0;59;0
WireConnection;65;0;63;0
WireConnection;92;0;65;0
WireConnection;92;1;85;0
WireConnection;91;0;62;0
WireConnection;91;1;84;0
WireConnection;93;0;91;0
WireConnection;93;1;92;0
WireConnection;89;0;91;0
WireConnection;89;1;92;0
WireConnection;94;1;93;0
WireConnection;94;0;89;0
WireConnection;94;2;91;0
WireConnection;90;0;94;0
WireConnection;73;0;90;0
WireConnection;73;1;74;0
WireConnection;75;0;73;0
WireConnection;34;0;62;0
WireConnection;34;1;65;0
WireConnection;35;0;62;0
WireConnection;35;1;65;0
WireConnection;43;0;46;0
WireConnection;43;1;49;0
WireConnection;81;1;41;0
WireConnection;81;0;82;0
WireConnection;41;0;42;0
WireConnection;41;1;43;0
WireConnection;83;0;75;0
WireConnection;83;1;82;4
WireConnection;83;2;72;0
WireConnection;46;0;45;0
WireConnection;46;1;47;0
WireConnection;46;2;48;0
WireConnection;49;0;48;0
WireConnection;49;1;44;0
WireConnection;48;0;33;0
WireConnection;33;1;35;0
WireConnection;33;0;34;0
WireConnection;33;2;62;0
WireConnection;1;2;81;0
WireConnection;1;3;83;0
ASEEND*/
//CHKSM=A62611E1145857FDAEAE1EAC93DFF3D5F4CC134B