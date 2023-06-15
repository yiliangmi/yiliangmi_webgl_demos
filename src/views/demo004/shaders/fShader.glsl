//用一个精度限定符声明片元着色器中浮点数的精度，这里使用中等精度
precision mediump float;
// 随机颜色
uniform vec4 u_color;
void main() {
    // gl_FragColor : 片元着色器的内置变量
    gl_FragColor = u_color;
}
