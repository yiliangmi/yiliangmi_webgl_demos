//用一个精度限定符声明片元着色器中浮点数的精度，这里使用中等精度
precision mediump float;

// 从顶点着色器传入的纹理坐标
varying vec2 v_texCoord;

// 纹理取样器
uniform sampler2D u_image0;
uniform sampler2D u_image1;

void main() {

    vec4 color0 = texture2D(u_image0, v_texCoord);
    vec4 color1 = texture2D(u_image1, v_texCoord);

    // 在纹理上寻找对应颜色值
    gl_FragColor = color0 * color1;

}
