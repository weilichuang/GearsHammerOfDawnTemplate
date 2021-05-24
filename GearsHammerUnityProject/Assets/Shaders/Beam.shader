Shader "Lexdev/GearsHammer/Beam"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _Emission("Emission", Color) = (1,1,1,1)

        _Sequence("Sequence Value", Range(0,1)) = 0.1

        _Width("Width Multiplier", Range(1,3)) = 2

        _NoiseFrequency("Noise Frequency", Range(1,100)) = 50.0
        _NoiseLength("Noise Length", Range(0.01,1.0)) = 0.25
        _NoiseIntensity("Noise Intensity", Range(0,0.1)) = 0.02
    }
    SubShader
    {
        CGPROGRAM

        #pragma surface surf Standard vertex:vert

        struct Input
        {
            float4 color;
        };

        fixed4 _Color;
        fixed4 _Emission;

        float _Sequence;

        float _Width;

        float _NoiseFrequency;
        float _NoiseLength;
        float _NoiseIntensity;
        
        void vert(inout appdata_full v)
        {
            float beamHeight = 20.0f;
            float scaledSeq = (1.0f - _Sequence) * 2.0f - 1.0f;
            float scaledSeqHeight = scaledSeq * beamHeight;
            float cosVal = cos(3.141f * (v.vertex.z / beamHeight - scaledSeq));
            float width = lerp(0.05f * (beamHeight - scaledSeqHeight + 0.5f), 
            cosVal, 
            pow(smoothstep(scaledSeqHeight - 8.0f, scaledSeqHeight, v.vertex.z), 0.1f));

            width = lerp(width,
            0.4f,
            smoothstep(scaledSeqHeight, scaledSeqHeight + 10.0f, v.vertex.z));

            v.vertex.xy *= width * _Width;

            v.vertex.xy += sin(_Time.y * _NoiseFrequency + v.vertex.z * _NoiseLength) * _NoiseIntensity * _Sequence;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = _Color.rgb;
            o.Emission = _Emission;
            o.Metallic = 0;
            o.Smoothness = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
