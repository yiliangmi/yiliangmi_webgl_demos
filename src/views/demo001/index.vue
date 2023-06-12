<template>
  <div class="home-wrap">
    <div class="home_header">绘制简单的多边形</div>
    <div class="home-content">
      <canvas id="myCanvas" class="myCanvas">
      </canvas>
    </div>
  </div>
</template>
<script>
import vShaderSource from './shaders/vShader.glsl';
import fShaderSource from './shaders/fShader.glsl'
export default {
  name: 'home',
  mounted() {
    let self = this;
    self.$nextTick(() => {
      self.init();
    })
  },
  data() {
    return{
      canvas: null,  // canvas对象
      gl: null,   // webgl上下文
      shaderProgram: null,  // 程序对象
      axisVertexBuffer: null,  //坐标轴缓冲区buffer
      rectangleVertexBuffer: null  //矩形缓冲区buffer
    }
  },
  methods: {
    async init() {
      await this.getGl();
      await this.loadShader();
      await this.setupBuffers();
      await this.draws();
    },
    /**
     * 获取webgl上下文
     */
    async getGl() {
      this.canvas = document.getElementById('myCanvas');
      let context = this.canvas.getContext('webgl') || this.canvas.getContext('experimental-webgl');
      if (context) {
        this.gl = context;
      }else{
        alert('浏览器不支持webgl');
      }
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
        alert('源码编译失败');
        return null;
      }


      // 创建程序对象
      this.shaderProgram = this.gl.createProgram();
      // 往程序对象中添加着色器
      this.gl.attachShader(this.shaderProgram, vShader);
      this.gl.attachShader(this.shaderProgram, fShader);
      // 连接着色器，如果连接成功，就得到一个程序对象
      this.gl.linkProgram(this.shaderProgram);
      // 判断是否连接成功
      if (!this.gl.getProgramParameter(this.shaderProgram, this.gl.LINK_STATUS)) {
        alert('程序连接错误');
        return null;
      }
      //告诉WebGL引擎可以用这个程序绘制对象
      this.gl.useProgram(this.shaderProgram);
    },
    /**
     * 设置缓冲区数据
     */
    async setupBuffers() {
      // 坐标轴缓冲区数据
      await this.setupAxisBuffers();
      // 矩形缓冲区数据
      this.setRectangleBuffers();
    },
    /**
     * 把坐标轴数据放进缓冲区
     */
    async setupAxisBuffers() {
      // 创建缓冲区，存放坐标轴数据（顶点数据和颜色数据）
      this.axisVertexBuffer = this.gl.createBuffer();

      // 坐标轴顶点
      let axisVertex = [
        //x轴xyz, rgba
        0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
        4.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0,

        //y轴xyz, rgba
        0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0,
        0.0, 4.0, 0.0, 0.0, 1.0, 0.0, 1.0,

        //z轴xyz, rgba
        0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 4.0, 0.0, 0.0, 1.0, 1.0,
      ];
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.axisVertexBuffer);
      //把顶点数据发送到绑定的缓冲
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(axisVertex), this.gl.STATIC_DRAW);
      // 清空绑定
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, null);
    },
    /**
     * 把矩形顶点坐标和颜色放进缓冲区
     */
    setRectangleBuffers() {
      // 创建矩形节点缓冲区
      this.rectangleVertexBuffer = this.gl.createBuffer();

      // 矩形节点和节点颜色
      let rectangleVertex = [
        // 第一个三角形： x,y,z,r,g,b,a
        0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0,
        -0.5, 0.5, 0.0, 0.0,1.0, 0.0, 1.0,
        -0.5, -0.5, 0.0, 0.0, 0.0, 1.0,1.0,
        // 第二个三角形： x,y,z,r,g,b,a
        0.5, 0.5, 0.0, 0.0,1.0, 0.0, 1.0,
        -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 1.0,
        0.5, -0.5, 0.0, 0.0, 0.0, 1.0,1.0,
      ];
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.rectangleVertexBuffer);
      //把顶点数据发送到绑定的缓冲
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(rectangleVertex),this.gl.STATIC_DRAW);
    },
    /**
     * 绘制
     */
    async draws() {

      //设置视口和画布
      this.setupViewport();

      // 绘制坐标轴
      await this.drawAxis();

      // 绘制矩形
      this.drawRectangle();
    },
    /**
     *  设置视口和画布
     */
    setupViewport() {
      // 设置视口
      this.gl.viewport(0.0, 0.0, this.canvas.width, this.canvas.height);
      // 设置清除画布的背景色
      this.gl.clearColor(0.0, 0.0, 0.0, 1.0);
      // 开启深度检测
      this.gl.enable(this.gl.DEPTH_TEST);
      // 清除画布
      this.gl.clear(this.gl.COLOR_BUFFER_BIT || this.gl.DEPTH_BUFFER_BIT);
    },
    /**
     * 绘制坐标轴
     */
    async drawAxis() {
      // 32位浮点数数组中每个元素所占用的字节数
      let FLOATSIZE = Float32Array.BYTES_PER_ELEMENT;

      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.axisVertexBuffer);

      // 获取顶点位置的索引
      let vertexPositionIndex = this.gl.getAttribLocation(this.shaderProgram, 'aVertexPosition');
      // 获取顶点颜色的索引
      let vertexColorIndex = this.gl.getAttribLocation(this.shaderProgram, 'aVertexColor');

      // 激活每一个属性以便使用，不被激活的属性是不会被使用的。
      // 一旦激活，以下其他方法就可以获取到属性的值了，包括vertexAttribPointer()，vertexAttrib*()，和 getVertexAttrib() (en-US)
      this.gl.enableVertexAttribArray(vertexPositionIndex);
      this.gl.enableVertexAttribArray(vertexColorIndex);

      // 告诉显卡从当前绑定的缓冲区（bindBuffer()指定的缓冲区）中读取顶点数据
      this.gl.vertexAttribPointer(vertexPositionIndex, 3, this.gl.FLOAT, false, 7 * FLOATSIZE, 0);
      this.gl.vertexAttribPointer(vertexColorIndex, 4, this.gl.FLOAT, false, 7 * FLOATSIZE, 3 * FLOATSIZE);

      // 开始绘制
      this.gl.drawArrays(this.gl.LINES, 0, 6);

      // 清空绑定
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, null);
    },
    /**
     * 绘制矩形
     */
    drawRectangle() {
      // 32位浮点数数组中每个元素所占用的字节数
      let FLOATSIZE = Float32Array.BYTES_PER_ELEMENT;
      // console.log(FLOATSIZE);   --输出4（4个字节）

      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.rectangleVertexBuffer);

      // 获取顶点位置的索引
      let vertexPositionIndex = this.gl.getAttribLocation(this.shaderProgram, 'aVertexPosition');
      // 获取顶点颜色的索引
      let vertexColorIndex = this.gl.getAttribLocation(this.shaderProgram, 'aVertexColor');

      // 激活每一个属性以便使用，不被激活的属性是不会被使用的。
      // 一旦激活，以下其他方法就可以获取到属性的值了，包括vertexAttribPointer()，vertexAttrib*()，和 getVertexAttrib() (en-US)
      this.gl.enableVertexAttribArray(vertexPositionIndex);
      this.gl.enableVertexAttribArray(vertexColorIndex);

      // 告诉显卡从当前绑定的缓冲区（bindBuffer()指定的缓冲区）中读取顶点数据
      this.gl.vertexAttribPointer(vertexPositionIndex, 3, this.gl.FLOAT, false, 7 * FLOATSIZE, 0);
      this.gl.vertexAttribPointer(vertexColorIndex, 4, this.gl.FLOAT, false, 7 * FLOATSIZE, 3 * FLOATSIZE);

      // 绘制三角形，从第0个点开始绘制。绘制需要使用到6个点。
      this.gl.drawArrays(this.gl.TRIANGLES, 0, 6);
    }
  }
}
</script>
<style scoped>
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
  width: 60vh;
  height: 60vh;
}

</style>
