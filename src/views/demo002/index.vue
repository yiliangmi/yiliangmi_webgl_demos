<template>
  <div class="home-wrap">
    <div class="home_header">利用屏幕像素坐标(左上角为坐标原点)绘制简单的三角形</div>
    <div class="home-content">
      <canvas ref="myCanvas" id="myCanvas" class="myCanvas">
      </canvas>
    </div>
  </div>
</template>

<script>
import vShaderSource from './shaders/vShader.glsl';
import fShaderSource from './shaders/fShader.glsl';
import {resizeCanvasToDisplaySize} from "@/utils/myCommon";

export default {
  name: "index",
  mounted() {
    let self = this;
    self.$nextTick(async () => {
      console.log('002')
      await self.init();
    })
  },
  data() {
    return {
      canvas: null, //canvas对象
      gl: null, //webgl上下文
      shaderProgram: null,  //着色器程序
      triangleVertexBuffer: null, // 三角形顶点坐标缓冲区
    }
  },
  methods: {
    //初始化程序
    async init() {
      //获取webgl上下文
      let isGlExist = await this.getGl();
      if (isGlExist) {
        await this.loadShader();
        await this.setupBuffers();
        await this.draws();
      }
    },
    /**
     * 绘制
     */
    async draws() {
      //设置视口和画布
      await this.setupViewPort();
      // 设置变量
      await this.setupVariables();
      // 绘制三角形
      await this.drawTriangle();
    },
    /**
     * 绘制三角形
     * @returns {Promise<void>}
     */
    async drawTriangle() {
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexBuffer);
      // 获取顶点位置的索引
      let vertexPositionIndex = this.gl.getAttribLocation(this.shaderProgram, 'a_position');
      // 激活每一个属性以便使用，不被激活的属性是不会被使用的。
      // 一旦激活，以下其他方法就可以获取到属性的值了，包括vertexAttribPointer()，vertexAttrib*()，和 getVertexAttrib() (en-US)
      this.gl.enableVertexAttribArray(vertexPositionIndex);
      //告诉显卡从当前绑定的缓冲区（bindBuffer()指定的缓冲区）中读取顶点数据
      // 告诉属性怎么从positionBuffer中读取数据 (ARRAY_BUFFER)
      this.gl.vertexAttribPointer(vertexPositionIndex, 2, this.gl.FLOAT, false, 0, 0);
      // 绘制三角形，从第0个点开始绘制。绘制需要使用到3个点。
      this.gl.drawArrays(this.gl.TRIANGLES, 0, 3);
    },
    /**
     * 设置变量
     * @returns {Promise<void>}
     */
    async setupVariables() {
      // 设置分辨率变量
      await this.setupUResolution();
    },
    /**
     * 设置分辨率变量
     * @returns {Promise<void>}
     */
    async setupUResolution() {
      // 获取分辨率变量在着色器程序中的索引位置
      let uResolutionIndex = this.gl.getUniformLocation(this.shaderProgram, 'u_resolution');
      // 给分辨率变量赋值
      this.gl.uniform2f(uResolutionIndex, this.gl.canvas.width, this.gl.canvas.height);
    },
    /**
     * 设置视口和画布
     * @returns {Promise<void>}
     */
    async setupViewPort() {
      // 设置画布的显示尺寸和 画布的drawingbuffer尺寸相同
      resizeCanvasToDisplaySize(this.gl.canvas);
      // 告诉WebGL如何将裁剪空间（-1 到 +1）中的点转换到像素空间， 也就是画布内
      this.gl.viewport(0, 0, this.gl.canvas.width, this.gl.canvas.height);
      // 设置清除画布的背景色
      this.gl.clearColor(0.0, 0.0, 0.0, 1.0);
      // 开启深度检测
      this.gl.enable(this.gl.DEPTH_BUFFER_BIT);
      // 清除画布
      this.gl.clear(this.gl.COLOR_BUFFER_BIT || this.gl.DEPTH_BUFFER_BIT);
    },
    async setupBuffers() {
      // 三角形缓冲数据
      await this.setTriangleBuffers();
    },
    /**
     * 设置三角形缓冲数据（屏幕像素坐标）
     * @returns {Promise<void>}
     */
    async setTriangleBuffers() {
      // 三角形顶点
      let triangleVertex = [
        20, 20,
        180, 20,
        20, 280
      ]
      // 创建三角形顶点缓冲区
      this.triangleVertexBuffer = this.gl.createBuffer();
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexBuffer);
      // 把顶点数据发送到绑定的缓冲区
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(triangleVertex), this.gl.STATIC_DRAW);

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
  height: 100%;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.myCanvas {
  margin: 15px 0;
  width: 600px;
  height: 600px;
}
</style>
