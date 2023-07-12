
// 属性变量（attribute）会接收来自缓冲区（buffer）的数据
attribute vec2 a_position;
// 顶点变换矩阵(二维)
uniform mat3 u_matrix;

// 纹理坐标（用来传递给片元着色器）
attribute vec2 a_texCoord;

// 'varying'变量将纹理坐标从顶点着色器传到片段着色器
varying vec2 v_texCoord;

void main() {
    // 顶点乘以变换矩阵，得到变换后的顶点坐标
    gl_Position = vec4((u_matrix * vec3(a_position, 1.0)).xy, 0.0, 1.0);

    // 将纹理坐标传给片段着色器
    // GPU会在点之间进行插值
    v_texCoord = a_texCoord;
}
