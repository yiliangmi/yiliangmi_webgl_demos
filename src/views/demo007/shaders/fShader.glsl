//用一个精度限定符声明片元着色器中浮点数的精度，这里使用中等精度
precision mediump float;

// 纹理取样器
uniform sampler2D u_image;

// 从顶点着色器传入的顶点坐标
varying vec2 v_position;

uniform vec2 u_point0;
uniform vec2 u_point1;
uniform vec2 u_point2;
uniform vec2 u_point3;

float calc(vec2 p1,vec2 p2,vec2 p3,vec2 p4,vec2 p0){
    float p12Xlen = p2.x - p1.x;
    float p12Ylen = p2.y - p1.y;
    float p34Xlen = p4.x - p3.x;
    float p34Ylen = p4.y - p3.y;
    float a = p12Xlen * p34Ylen -p12Ylen * p34Xlen;
    float b = p1.x * p34Ylen + p3.y * p12Xlen - p0.y * p12Xlen - p3.x * p12Ylen + p0.y * p34Xlen - p1.y * p34Xlen + p0.x * (p12Ylen - p34Ylen);
    float c = p3.x * p0.y - p3.x * p1.y + p1.x * p3.y - p1.x * p0.y + p0.x * (p1.y - p3.y);
    //两条线都垂直于x轴或者y轴的情况下
    if(a == 0.0){
        return -c / b;
    }
    //两条线不平行的情况下
    float endA = (-b + sqrt(b * b - 4.0*a*c)) / (2.0*a);
    float endB = (-b - sqrt(b*b - 4.0*a*c)) / (2.0*a);
    if(endA > 0.0 && endA < 1.0){
        return endA;
    }
    if(endB > 0.0 && endB < 1.0){
        return endB;
    }else{
        return -c / b;
    }
}
//两个点的位置，第一个calc（v0,v2,v1,v3,p0） 第二个calc(v1,v0,v3,v2,p0)
void main() {
    vec2 uv_c = vec2(calc(u_point0,u_point2,u_point1,u_point3,v_position),calc(u_point1,u_point0,u_point3,u_point2,v_position));
    // 在纹理上寻找对应颜色值
    gl_FragColor = texture2D(u_image, uv_c);

}
