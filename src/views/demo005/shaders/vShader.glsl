
// 属性变量（attribute）会接收来自缓冲区（buffer）的数据
attribute vec2 a_position;
// 顶点变换矩阵(二维)
uniform mat3 u_matrix;

void main() {
    // 顶点乘以变换矩阵，得到变换后的顶点坐标
    gl_Position = vec4((u_matrix * vec3(a_position, 1.0)).xy,0.0,1.0);
}
