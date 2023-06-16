/**
 * 每个画布都有两个尺寸，一个是 drawingbuffer 的尺寸， 这个表示画布中有多少个像素。另一是画布显示的尺寸， CSS决定画布显示的尺寸
 * 设置画布的显示尺寸和 画布的drawingbuffer尺寸相同
 * @param canvas canvas对象
 * @returns {boolean}
 */
export function resizeCanvasToDisplaySize(canvas) {
    // Lookup the size the browser is displaying the canvas in CSS pixels.
    const displayWidth = canvas.clientWidth;
    const displayHeight = canvas.clientHeight;

    // Check if the canvas is not the same size.
    const needResize = canvas.width !== displayWidth ||
        canvas.height !== displayHeight;

    if (needResize) {
        // Make the canvas the same size
        canvas.width = displayWidth;
        canvas.height = displayHeight;
    }

    return needResize;
}
/**
 * 创建并编译一个着色器
 *
 * @param {!WebGLRenderingContext} gl WebGL上下文。
 * @param {string} shaderSource GLSL 格式的着色器代码
 * @param {number} shaderType 着色器类型, VERTEX_SHADER 或
 *     FRAGMENT_SHADER。
 * @return {!WebGLShader} 着色器。
 */
export function compileShader(gl, shaderSource, shaderType) {
    // 创建着色器程序
    let shader = gl.createShader(shaderType);

    // 设置着色器的源码
    gl.shaderSource(shader, shaderSource);

    // 编译着色器
    gl.compileShader(shader);

    // 检测编译是否成功
    let success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (!success) {
        // 编译过程出错，获取错误信息。
        throw "could not compile shader:" + gl.getShaderInfoLog(shader);
    }

    return shader;
}
/**
 * 从 2 个着色器中创建一个程序
 *
 * @param {!WebGLRenderingContext) gl WebGL上下文。
 * @param {!WebGLShader} vertexShader 一个顶点着色器。
 * @param {!WebGLShader} fragmentShader 一个片段着色器。
 * @return {!WebGLProgram} 程序
 */
export function createProgram(gl, vertexShader, fragmentShader) {
    // 创建一个程序
    let program = gl.createProgram();

    // 附上着色器
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);

    // 链接到程序
    gl.linkProgram(program);

    // 检查链接是否成功
    let success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (!success) {
        // 链接过程出现问题
        throw ("program failed to link:" + gl.getProgramInfoLog (program));
    }

    return program;
};
