
// 属性变量（attribute）会接收来自缓冲区（buffer）的数据
attribute vec2 a_position;

// 接收canvas分辨率
uniform vec2 u_resolution;

void main() {
    // 从像素坐标转换到 0.0 到 1.0
    vec2 zeroToOne = a_position / u_resolution;
    // 再把 0->1 转换 0->2
    vec2 zeroToTwo = zeroToOne * 2.0;
    // 把 0->2 转换到 -1->+1 (裁剪空间)
    vec2 clipSpace = zeroToTwo - 1.0;

    gl_Position = vec4(clipSpace,0.0,1.0);


}
