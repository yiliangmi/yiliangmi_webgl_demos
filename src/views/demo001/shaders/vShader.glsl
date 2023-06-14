// 属性变量（attribute）会接收来自缓冲区（buffer）的数据
attribute vec4 a_position;

void main() {
    // // gl_Position : 顶点着色器的内置变量，顶点位置
    gl_Position = a_position;
}
