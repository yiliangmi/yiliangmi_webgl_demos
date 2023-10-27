
// 属性变量（attribute）会接收来自缓冲区（buffer）的数据
attribute vec4 a_position;
attribute vec4 a_color;
attribute vec3 a_normal;

// 顶点变换矩阵(四维矩阵)
// uniform mat4 u_matrix;

// 把u_matrix改成传递两个矩阵
// u_world : 世界矩阵
// u_worldViewProjection == u_matrix
uniform mat4 u_worldViewProjection;
uniform mat3 u_worldInverseTranspose;

// 顶点颜色
varying vec4 v_color;
// 传递法向量
varying vec3 v_normal;

void main() {
    // 顶点乘以变换矩阵，得到变换后的顶点坐标
    gl_Position = u_worldViewProjection * a_position;

    v_color = a_color;

    // 重定向法向量并传递给片段着色器
    // 注意到我们将 a_normal 与 mat3(u_world) 相乘， 那是因为法向量是方向所以不用关心位移， 矩阵的左上 3x3 部分才是控制姿态的
    v_normal = u_worldInverseTranspose * a_normal;

}
