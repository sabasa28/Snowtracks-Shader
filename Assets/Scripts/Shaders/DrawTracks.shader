Shader "Unlit/DrawTracks"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Coordinate("Coordinate", Vector) = (0,0,0,0)
        _Color("Draw Color", Color) = (1,0,0,0)
        _FootprintTex("Footprint Texture", 2D) = "white" {}
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
            float4 _MainTex_ST;
            fixed4 _Coordinate;
            fixed4 _Color;
            //float _PencilThickness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //Transforms a point from object space to the camera’s clip space in homogeneous coordinates.This is the equivalent of mul(UNITY_MATRIX_MVP, float4(pos, 1.0)), and should be used in its place.
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); // Transforms 2D UV by scale/bias property
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //_PencilThickness - 

                fixed4 col = tex2D(_MainTex, i.uv);
                float draw = pow(saturate(1 - distance(i.uv, _Coordinate.xy)), 200); //aca hacer un clamp y hacer algo como pencilthickness - 200 o algo
                fixed4 drawcol = _Color * (draw * 0.5); // float = growspeed
                return saturate(col + drawcol);
            }
            ENDCG
        }
    }
}
