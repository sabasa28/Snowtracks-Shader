Shader "Custom/Page4"
{
    Properties
    {
       _Color("Main Color", Color) = (1,1,1,1)
       _MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
       _BlendTex("Blend (RGB)", 2D) = "white"
       _BlendAlpha("Blend Alpha", float) = 0
    }
       
     SubShader
    {
       Tags { "Queue" = "Geometry-9" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
       Lighting Off
       LOD 200
       Blend SrcAlpha OneMinusSrcAlpha
    
       CGPROGRAM
       #pragma surface surf Lambert alpha
    
       fixed4 _Color;
       sampler2D _MainTex;
       sampler2D _BlendTex;
       float _BlendAlpha;
    
       struct Input {
         float2 uv_MainTex;
       };
    
       void surf(Input IN, inout SurfaceOutput o) {
           fixed4 tex1 = tex2D(_MainTex, IN.uv_MainTex);
           fixed4 tex2 = tex2D(_BlendTex, IN.uv_MainTex);
           fixed4 c;
           if (tex1.r > tex2.r)
               c = tex1;
           else
               c = tex2;
           
           //c = fixed4(tex1.r, 0, 0, tex1.r);
           //c = ((1 - _BlendAlpha) * tex1 + _BlendAlpha * tex2);
           //c = tex1 + tex2;
           //c = lerp (tex1 , tex2 , 1);

           o.Albedo = c.rgba;
           o.Alpha = c.a;
       }
       ENDCG
    }
    
    Fallback "Transparent/VertexLit"
}
