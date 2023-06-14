
//用一个精度限定符声明片元着色器中浮点数的精度，这里使用中等精度
precision mediump float;

void main() {
    // gl_FragColor : 片元着色器的内置变量
    gl_FragColor = vec4(1, 0, 0.5, 1);
}
