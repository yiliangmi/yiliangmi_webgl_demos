//用一个精度限定符声明片元着色器中浮点数的精度，这里使用中等精度
precision mediump float;
// 顶点颜色
varying vec4 v_color;
// 顶点法向量
varying vec3 v_normal;

//光线方向
uniform vec3 u_reverseLightDirection;

void main() {

    // 由于 v_normal 是插值出来的，和有可能不是单位向量，
    // 可以用 normalize 将其单位化。
    vec3 normal = normalize(v_normal);

    float light = dot(normal, u_reverseLightDirection);

    // gl_FragColor : 片元着色器的内置变量
    gl_FragColor = v_color;

    // 将颜色部分（不包括 alpha）和 光照相乘
    gl_FragCoord.rgb *= light;
}
