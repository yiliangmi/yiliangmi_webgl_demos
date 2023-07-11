//用一个精度限定符声明片元着色器中浮点数的精度，这里使用中等精度
precision mediump float;

// 从顶点着色器传入的纹理坐标
varying vec2 v_texCoord;

// 纹理
uniform sampler2D u_image;
uniform vec2 u_textureSize;
uniform float u_kernel[9];
uniform float u_kernelWeight;


void main() {

    vec2 onePixel = vec2(1.0, 1.0) / u_textureSize;
    vec4 colorSum =
    texture2D(u_image, v_texCoord + onePixel * vec2(-1, -1)) * u_kernel[0] +
    texture2D(u_image, v_texCoord + onePixel * vec2( 0, -1)) * u_kernel[1] +
    texture2D(u_image, v_texCoord + onePixel * vec2( 1, -1)) * u_kernel[2] +
    texture2D(u_image, v_texCoord + onePixel * vec2(-1,  0)) * u_kernel[3] +
    texture2D(u_image, v_texCoord + onePixel * vec2( 0,  0)) * u_kernel[4] +
    texture2D(u_image, v_texCoord + onePixel * vec2( 1,  0)) * u_kernel[5] +
    texture2D(u_image, v_texCoord + onePixel * vec2(-1,  1)) * u_kernel[6] +
    texture2D(u_image, v_texCoord + onePixel * vec2( 0,  1)) * u_kernel[7] +
    texture2D(u_image, v_texCoord + onePixel * vec2( 1,  1)) * u_kernel[8] ;

    // 只把rgb值求和除以权重
    // 将阿尔法值设为 1.0
    gl_FragColor = vec4((colorSum / u_kernelWeight).rgb, 1.0);

}
