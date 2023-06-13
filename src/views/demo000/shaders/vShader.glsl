// attribute:属性变量，特殊的输入变量，利用它们把顶点数据从WebGL Api传送到顶点着色器
// 定义顶点位置
attribute vec3 aVertexPosition;
// 定义顶点颜色
attribute vec4 aVertexColor;
// 颜色变量-片元颜色
varying vec4 vColor;

void main() {
    //所有顶点着色器都必须给预定义变量gl_Position赋一个值。当顶点着色器结束处理一个顶点时，这
    //  个变量保存了它的位置，并将其传递给WebGL流水线的下一个阶段。
    gl_Position = vec4(aVertexPosition, 1.0);
    vColor = aVertexColor;
}
