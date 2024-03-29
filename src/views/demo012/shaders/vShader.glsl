
// 属性变量（attribute）会接收来自缓冲区（buffer）的数据
attribute vec4 a_position;
attribute vec4 a_color;

// 顶点变换矩阵(四维矩阵)
uniform mat4 u_matrix;

// 顶点颜色
varying vec4 v_color;

void main() {
    // 顶点乘以变换矩阵，得到变换后的顶点坐标
    gl_Position = u_matrix * a_position;

    v_color = a_color;

}
