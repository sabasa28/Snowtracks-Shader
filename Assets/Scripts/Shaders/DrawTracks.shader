Shader "Unlit/DrawTracks"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DividedIn("DividedIn", Int) = 10
        _FootTexU ("FootTextureU", 2D) = "white" {}
        _FootTexD ("FootTextureD", 2D) = "white" {}
        _FootSize ("FootSize", Int) = 0
        _FlipFoot("FlipFoot", Int) = 0
        _StepRot("StepRot", Float) = 0.0
        _Coordinate("Coordinate", Vector) = (0,0,0,0)
        _Color("Draw Color", Color) = (1,0,0,0)
        //_PencilThickness("Pencil Thickness", Range (0, 200)) = 50.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _FootTexU;
            sampler2D _FootTexD;
            float _StepRot;
            int _FlipFoot;
            int _DividedIn;
            float4 _MainTex_ST;
            fixed4 _Coordinate;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //Transforms a point from object space to the camera’s clip space in homogeneous coordinates.This is the equivalent of mul(UNITY_MATRIX_MVP, float4(pos, 1.0)), and should be used in its place.
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); // Transforms 2D UV by scale/bias property
                return o;
            }

            float2 rotateUV(float2 uv, float2 pivot, float rotation) {
                float sine = sin(rotation);
                float cosine = cos(rotation);
                float aux;
                
                uv -= pivot;
                aux = uv.x;
                uv.x = uv.x * cosine - uv.y * sine;
                uv.y = aux * sine + uv.y * cosine;
                uv += pivot;

                return uv;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 coordsToLimit = float2(round(_Coordinate.x * 10) / 10, round(_Coordinate.y * 10) / 10);
                float2 coordsToDraw = _Coordinate.xy;
                float2 uv = i.uv;
                //if (_FlipFoot == 0) float2 (1.0 - i.uv.x, i.uv.y);
                uv = rotateUV(uv, coordsToDraw, _StepRot * 0.01745329251);
                float2 uvToShow = uv;
                fixed4 used;
                fixed4 foot;
                if (_FlipFoot == 0) foot = tex2D(_FootTexU, uv * _DividedIn);
                else foot = tex2D(_FootTexD, uv * _DividedIn);
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 limit1 = coordsToLimit;
                float2 limit2 = coordsToLimit + float2(1.0 / _DividedIn, 1.0 / _DividedIn);
                if (uvToShow.x > limit1.x && uvToShow.y > limit1.y && uvToShow.x < limit2.x && uvToShow.y < limit2.y)
                        used = foot;
                    else
                        used = col;

                //if (_FlipFoot == 0)
                //{
                //    if (uvToShow.x < limit.x && uvToShow.y < limit.y)
                //        used = foot;
                //    else
                //        used = col;
                //}
                //else
                //{
                //    if (uvToShow.x > limit.x && uvToShow.y < limit.y)
                //        used = foot;
                //    else
                //        used = col;
                //}

                float draw = pow(saturate(1 - distance(i.uv, _Coordinate.xy)), 200);
                fixed4 drawcol = _Color * (draw * 0.5);
                return saturate(used);
            }

            ENDCG
        }
    }
}
