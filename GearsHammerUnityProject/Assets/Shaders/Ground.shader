Shader "Lexdev/GearsHammer/Ground"
{
    Properties
    {
        _Sequence("Sequence", Range(0,1)) = 0.0

        _Noise("Noise Texture", 2D) = "white" {}

        _Exp("Shape Exponent", Range(1.0,10.0)) = 5.0
        _Rot("Rotation Multiplier", Range(1.0,100.0)) = 50.0
        _Height("Height Multiplier", Range(0.1,1.0)) = 0.5
    }

    SubShader
    {
        CGPROGRAM

        #pragma surface surf Standard vertex:vert

        struct Input
        {
            float3 color;
        };

        float _Sequence;
        sampler2D _Noise;

        float _Exp;
        float _Rot;
        float _Height;

        void Rotate(inout float4 vertex, inout float3 normal, float3 center, float3 around, float angle)
        {
            float4x4 translation = float4x4(
            1, 0, 0, center.x,
            0, 1, 0, -center.y,
            0, 0, 1, -center.z,
            0, 0, 0, 1);
            float4x4 translationT = float4x4(
            1, 0, 0, -center.x,
            0, 1, 0, center.y,
            0, 0, 1, center.z,
            0, 0, 0, 1);

            around.x = -around.x;
            around = normalize(around);
            float s = sin(angle);
            float c = cos(angle);
            float ic = 1.0 - c;

            float4x4 rotation = float4x4(
            ic * around.x * around.x + c, ic * around.x * around.y - s * around.z, ic * around.z * around.x + s * around.y, 0.0,
            ic * around.x * around.y + s * around.z, ic * around.y * around.y + c, ic * around.y * around.z - s * around.x, 0.0,
            ic * around.z * around.x - s * around.y, ic * around.y * around.z + s * around.x, ic * around.z * around.z + c, 0.0,
            0.0, 0.0, 0.0, 1.0);

            vertex = mul(translationT, mul(rotation, mul(translation, vertex)));
            normal = mul(translationT, mul(rotation, mul(translation, float4(normal, 0.0f)))).xyz;
        }

        void vert(inout appdata_full v,out Input i)
        {
            float noise = tex2Dlod(_Noise, v.texcoord * 2.0f).r;
            float2 uvDir = v.texcoord.xy - 0.5f;

            float scaledSequence = _Sequence * 1.52f - 0.02f;

            float seqVal = pow(1.0f - (noise + 1.0f) * length(uvDir), _Exp) * scaledSequence;

            Rotate(v.vertex, v.normal, float3(2.0f * uvDir, 0), cross(float3(uvDir, 0), float3(noise * 0.1f, 0, 1)), seqVal * _Rot);

            v.vertex.z += sin(seqVal * 2.0f) * (noise + 1.0f) * _Height;
            v.vertex.xy -= normalize(float2(v.texcoord.x, 1.0f - v.texcoord.y) - 0.5f) * seqVal * noise * 2.0f;
            
            i.color = float3(1,1,1);
        }

        void surf (Input i, inout SurfaceOutputStandard o)
        {
            o.Albedo = i.color;
            o.Metallic = 0;
            o.Smoothness = 1;
        }

        ENDCG
    }
}
