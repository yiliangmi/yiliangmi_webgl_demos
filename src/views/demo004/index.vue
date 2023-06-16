<template>
  <div class="home-wrap">
    <div class="home_header">二维矩阵之绕原点旋转的F字母</div>
    <div>
      <h4>tips</h4>
      <ul>
        <li>我们总是绕原点旋转，而 'F' 的原点就是左上角，也就是 (0, 0)</li>
        <li>使用二维矩阵m3.projection()简化从像素坐标(左上角为坐标原点)到裁剪坐标（坐标范围是 -1 到 +1）的转换</li>
        <li>矩阵顺序：projectionMat * translationMat * rotationMat * scaleMat * position</li>
      </ul>
    </div>
    <div class="home-content">
      <ToolBar :x-max="xMax" :y-max="yMax" @updateScene="updateScene"></ToolBar>
      <canvas ref="myCanvas" id="myCanvas" class="myCanvas">
      </canvas>
    </div>
  </div>
</template>

<script>
import ToolBar from "@/components/ToolBar/ToolBar.vue";
import fShaderSource from './shaders/fShader.glsl';
import vShaderSource from './shaders/vShader.glsl';
import {resizeCanvasToDisplaySize} from "@/utils/myCommon";
import {mat3, glMatrix} from "gl-matrix";

export default {
  name: "index",
  components: {ToolBar},
  data() {
    return{
      xMax: this.gl ? this.gl.canvas.width : 100,
      yMax: this.gl ? this.gl.canvas.height : 100,
      sliderBar: {
        xVal: 0, // x轴平移
        yVal: 0, // y轴平移
        angleVal: 0, // 旋转角度
        scaleXVal: 1, // x轴方向缩放
        scaleYVal: 1, // y轴方向缩放
      },  // 滑块对象
      canvas: null, //canvas对象
      gl: null,  //webgl上下文,
      shaderProgram: null,  //着色器程序
      fVertexBuffer: null,  //字母f顶点坐标缓冲区
      uMatrix: mat3.create()  //生成 mat3 单位矩阵
    }
  },
  mounted() {
    let self = this;
    self.$nextTick(async () => {
      await self.init();
    })
  },
  methods:{
    async init() {
      //获取webgl上下文
      let isGlExist = await this.getGl();
      if (isGlExist) {
        await this.loadShader();
        //设置片元着色器颜色变量
        await this.setUColor();
        // 绘制场景
        await this.drawScene();
      }
    },
    /**
     * 更新场景绘制
     * @param sliderBarVal
     */
    updateScene(sliderBarVal) {
      this.sliderBar = sliderBarVal;
      if (this.gl) {
        this.drawScene();
      }
    },
    /**
     * 绘制场景
     * @returns {Promise<void>}
     */
    async drawScene() {
      //设置视口和画布
      await this.setupViewPort();
      // 设置顶点的二维变换矩阵
      await this.setUMatrix();
      //设置字母F的缓冲数据（屏幕像素坐标）
      await this.setFBuffers();
      // 绘制字母F
      await this.drawF();
    },
    /**
     * 绘制字母F
     * @returns {Promise<void>}
     */
    async drawF() {
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.fVertexBuffer);

      // 获取顶点位置的索引
      let fLocation = this.gl.getAttribLocation(this.shaderProgram, 'a_position');

      // 激活每一个属性以便使用，不被激活的属性是不会被使用的。
      // 一旦激活，以下其他方法就可以获取到属性的值了，包括vertexAttribPointer()，vertexAttrib*()，和 getVertexAttrib() (en-US)
      this.gl.enableVertexAttribArray(fLocation);

      //告诉显卡从当前绑定的缓冲区（bindBuffer()指定的缓冲区）中读取顶点数据
      // 告诉属性怎么从positionBuffer中读取数据 (ARRAY_BUFFER)
      this.gl.vertexAttribPointer(fLocation, 2, this.gl.FLOAT, false, 0, 0);

      //  'F'有6个三角形，每个三角形需要3个点，共18个点
      this.gl.drawArrays(this.gl.TRIANGLES, 0, 18);
    },
    /**
     * 设置顶点的二维变换矩阵
     * @returns {Promise<void>}
     */
    async setUMatrix() {
      //设置  mat3 为单位矩阵
      this.uMatrix = mat3.identity(this.uMatrix);
      // 按照投影矩阵*平移矩阵*旋转矩阵*缩放矩阵*顶点坐标进行空间变换
      // 1.把屏幕像素坐标（左上角为坐标原点）转换为裁剪坐标（坐标范围是 -1 到 +1）
      this.uMatrix = mat3.projection(this.uMatrix, this.gl.canvas.clientWidth, this.gl.canvas.clientHeight);
      // 2.设置平移矩阵
      this.uMatrix = mat3.translate(this.uMatrix, this.uMatrix, [this.sliderBar.xVal, this.sliderBar.yVal]);
      // 3.设置旋转矩阵
      this.uMatrix = mat3.rotate(this.uMatrix, this.uMatrix, glMatrix.toRadian(this.sliderBar.angleVal));
      // 4.设置缩放矩阵
      this.uMatrix = mat3.scale(this.uMatrix, this.uMatrix, [this.sliderBar.scaleXVal, this.sliderBar.scaleYVal]);

      // 获取uMatrix在着色器程序中的位置
      let uMatrixLocation = this.gl.getUniformLocation(this.shaderProgram, 'u_matrix');
      // 设置uMatrix的值
      this.gl.uniformMatrix3fv(uMatrixLocation, false, this.uMatrix);
    },
    /**
     * 设置字母F的缓冲数据（屏幕像素坐标）
     * @returns {Promise<void>}
     */
    async setFBuffers() {

      // 字母F的顶点
      let fVertex = [
        // 左侧列
        0, 0,
        30, 0,
        0, 150,
        0, 150,
        30, 0,
        30, 150,

        // 上横杠
        30, 0,
        100, 0,
        30, 30,
        30, 30,
        100, 0,
        100, 30,

        // 中横杠
        30, 60,
        67, 60,
        30, 90,
        30, 90,
        67, 60,
        67, 90,
      ]

      // 创建字母F的缓冲区
      this.fVertexBuffer = this.gl.createBuffer();
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.fVertexBuffer);
      // 把顶点数据发送到绑定的缓冲区
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(fVertex), this.gl.STATIC_DRAW);
    },
    /**
     * 获取片元着色器颜色变量位置
     */
    async setUColor() {
      // 获取片元着色器颜色变量位置
      let uColorLocation = this.gl.getUniformLocation(this.shaderProgram, 'u_color');
      this.gl.uniform4f(uColorLocation, Math.random(), Math.random(), Math.random(), 1.0);
    },
    /**
     * 设置视口和画布
     * @returns {Promise<void>}
     */
    setupViewPort() {
      // 设置画布的显示尺寸和 画布的drawingbuffer尺寸相同
      resizeCanvasToDisplaySize(this.gl.canvas);
      this.xMax = this.gl.canvas.width;
      this.yMax = this.gl.canvas.height;
      // 告诉WebGL如何将裁剪空间（-1 到 +1）中的点转换到像素空间， 也就是画布内
      this.gl.viewport(0, 0, this.gl.canvas.width, this.gl.canvas.height);
      // 设置清除画布的背景色
      this.gl.clearColor(0.0, 0.0, 0.0, 1.0);
      // 清除画布
      this.gl.clear(this.gl.COLOR_BUFFER_BIT || this.gl.DEPTH_BUFFER_BIT);

    },
    /**
     * 获取webgl上下文
     */
    async getGl() {
      this.canvas = this.$refs.myCanvas;
      this.gl = this.canvas.getContext('webgl') || this.canvas.getContext('experimental-webgl');
      if (!this.gl) {
        alert('浏览器不支持webgl');
        return false;
      }

      return true;
    },
    /**
     * 加载shader和着色器程序
     */
    async loadShader() {
      // 创建顶点着色器
      let vShader = this.gl.createShader(this.gl.VERTEX_SHADER);
      // 加载顶点着色器源码
      this.gl.shaderSource(vShader, vShaderSource);
      // 编译顶点着色器
      this.gl.compileShader(vShader);

      // 创建片元着色器
      let fShader = this.gl.createShader(this.gl.FRAGMENT_SHADER);
      // 加载片元着色器源码
      this.gl.shaderSource(fShader, fShaderSource);
      // 编译片元着色器
      this.gl.compileShader(fShader);

      // 判断顶点/片元着色器是否编译成功
      if (!this.gl.getShaderParameter(vShader, this.gl.COMPILE_STATUS) || !this.gl.getShaderParameter(fShader, this.gl.COMPILE_STATUS)) {
        console.log('源码编译失败');
        this.gl.deleteShader(vShader);
        this.gl.deleteShader(fShader);
        return;
      }
      // 创建着色程序
      this.shaderProgram = this.gl.createProgram();
      // 往着色程序中添加着色器
      this.gl.attachShader(this.shaderProgram, vShader);
      this.gl.attachShader(this.shaderProgram, fShader);
      // 连接着色程序，如果连接成功，就得到一个程序对象
      this.gl.linkProgram(this.shaderProgram);
      // 判断是否连接成功
      if (!this.gl.getProgramParameter(this.shaderProgram, this.gl.LINK_STATUS)) {
        console.log('程序连接错误');
        this.gl.deleteProgram(this.shaderProgram);
        return;
      }
      // 告诉webgl引擎可以使用这个着色程序绘制对象
      this.gl.useProgram(this.shaderProgram);
    }
  }
}
</script>

<style lang="scss" scoped>
.home-wrap {
  width: 100%;
  height: 100%;
}

.home_header {
  width: 100%;
  height: 8vh;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: large;
  letter-spacing: 5px;
  font-weight: bold;
}

.home-content {
  margin: 40px 0;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  flex-direction: column;
}

.myCanvas {
  width: 600px;
  height: 600px;
  position: relative;
}

</style>
