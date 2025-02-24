#if defined(SH_DEGREE_1)
    #define SH_DEGREE 1
#elif defined(SH_DEGREE_2)
    #define SH_DEGREE 2
#elif defined(SH_DEGREE_3)
    #define SH_DEGREE 3
#else
    #define SH_DEGREE 0
#endif

#define SH_DIM ((SH_DEGREE + 1) * (SH_DEGREE + 1))

static const float C0 = 0.28209479177387814f;
static const float C1 = 0.4886025119029199f;
static const float C2[5] = { 1.0925484305920792f, -1.0925484305920792f, 0.31539156525252005f, -1.0925484305920792f, 0.5462742152960396f };
static const float C3[7] = { -0.5900435899266435f, 2.890611442640554f, -0.4570457994644658f, 0.3731763325901154f, -0.4570457994644658f, 1.445305721320277f, -0.5900435899266435f };

void sh_coefficients(float3 dir, out float sh[SH_DIM]) {
    float x = dir.x;
    float y = dir.y;
    float z = dir.z;

    sh[0] = C0 + 0.5;

    if (SH_DEGREE > 0) {
        sh[1] = -C1 * y;
        sh[2] = C1 * z;
        sh[3] = -C1 * x;
    }
    float xx = x * x, yy = y * y, zz = z * z;
    float xy = x * y, yz = y * z, xz = x * z;
    if (SH_DEGREE > 1) {
        sh[4] = C2[0] * xy;
        sh[5] = C2[1] * yz;
        sh[6] = C2[2] * (2.0f * zz - xx - yy);
        sh[7] = C2[3] * xz;
        sh[8] = C2[4] * (xx - yy);
    }
    if (SH_DEGREE > 2) {
        sh[9] = C3[0] * y * (3.0f * xx - yy);
        sh[10] = C3[1] * xy * z;
        sh[11] = C3[2] * y * (4.0f * zz - xx - yy);
        sh[12] = C3[3] * z * (2.0f * zz - 3.0f * xx - 3.0f * yy);
        sh[13] = C3[4] * x * (4.0f * zz - xx - yy);
        sh[14] = C3[5] * z * (xx - yy);
        sh[15] = C3[6] * x * (xx - 3.0f * yy);
    }
}

float3 load_sh_as_rgb(float coeffs[SH_DIM], float harmonics[SH_DIM * 3]) {
    float3 rgb = float3(1.0f, 1.0f, 1.0f) * 0.0f; // ? FIXME: original code has 0.5 here..

    [unroll(3 * SH_DIM)]
    for (uint i = 0; i < 3 * SH_DIM; i++) {
        rgb[i % 3] += coeffs[i / 3] * harmonics[i];
    }

    return max(0, rgb);
}