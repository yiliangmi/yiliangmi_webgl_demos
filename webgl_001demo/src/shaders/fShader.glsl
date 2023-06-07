//用一个精度限定符声明片元着色器中浮点数的精度，这里使用中等精度
precision mediump float;
// 颜色变量-片元颜色
varying vec4 vColor;

void main() {
    //顶点颜色，根据节点着色器传来的vColor值进行处理后的输出颜色
    gl_FragColor = vColor;
}
