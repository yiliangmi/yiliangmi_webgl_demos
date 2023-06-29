<template>
  <div class="home-wrap">
    <div class="home_header">简单的纹理</div>
    <div>
      <h4>tips</h4>
      <ul>
        <li>渲染纹理时需要纹理坐标，而不是像素坐标</li>
        <li>无论纹理是什么尺寸，纹理坐标范围始终是 0.0 到 1.0(很重要)</li>
        <li>为什么u_image没有设置还能正常运行？全局变量默认为 0 所以 u_image 默认使用纹理单元 0 。 纹理单元 0 默认为当前活跃纹理，所以调用 bindTexture 会将纹理绑定到单元 0</li>
      </ul>
    </div>
    <div class="home-content">
      <canvas ref="myCanvas" id="myCanvas" class="myCanvas">
      </canvas>
    </div>
  </div>
</template>

<script>
import fShaderSource from './shaders/fShader.glsl';
import vShaderSource from './shaders/vShader.glsl';
import {resizeCanvasToDisplaySize} from "@/utils/myCommon";
import {mat3, glMatrix} from "gl-matrix";

export default {
  name: "index",
  data() {
    return{
      canvas: null, //canvas对象
      gl: null,  //webgl上下文,
      shaderProgram: null,  //着色器程序
      polygonVertexBuffer: null,  //多边形顶点坐标缓冲区
      texCoordBuffer: null,  //纹理坐标缓冲区
      polygonTexture: null,  //纹理
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
        // 绘制场景
        await this.drawScene();
      }
    },
    /**
     * 绘制场景
     * @returns {Promise<void>}
     */
    async drawScene() {

      // 设置顶点的二维变换矩阵
      await this.setUMatrix();
      //设置多边形的缓冲数据（屏幕像素坐标）
      await this.setPolygonBuffers();
      // 设置纹理坐标的缓冲数据
      await this.setTexCoordBuffers();
      // 设置纹理
      // 图片是异步加载的，所以我们需要等待纹理加载，一旦加载完成就开始绘制
      await this.setupTextures();
      //设置视口和画布
      await this.setupViewPort();
      // 绘制多边形
      await this.drawPolygon();

    },
    /**
     * 设置纹理
     */
    async setupTextures() {
      return new Promise(((resolve, reject) => {
        this.polygonTexture = this.gl.createTexture();
        let image = new Image();
        image.src = require('./textures/test.png')
        image.onload = async () => {
          await this.handleTextureLoaded(image, this.polygonTexture);
          resolve(true);
        }
      }))

    },
    /**
     * 图片加载后上传至纹理
     * @param image
     * @param texture
     * @returns {Promise<void>}
     */
    async handleTextureLoaded(image, texture) {
      //通过把新创建的纹理对象绑定到 gl.TEXTURE_2D 来让它成为当前操作纹理
      this.gl.bindTexture(this.gl.TEXTURE_2D, texture);

      // 设置参数，让我们可以绘制任何尺寸的图像
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_S, this.gl.CLAMP_TO_EDGE);
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_T, this.gl.CLAMP_TO_EDGE);
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MIN_FILTER, this.gl.NEAREST);
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MAG_FILTER, this.gl.NEAREST);

      // 将图像上传到纹理
      this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image);

    },
    /**
     * 绘制多边形
     * @returns {Promise<void>}
     */
    async drawPolygon() {


      /*-----------顶点坐标------------*/

      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.polygonVertexBuffer);

      // 获取顶点位置的索引
      let polygonLocation = this.gl.getAttribLocation(this.shaderProgram, 'a_position');

      // 激活每一个属性以便使用，不被激活的属性是不会被使用的。
      // 一旦激活，以下其他方法就可以获取到属性的值了，包括vertexAttribPointer()，vertexAttrib*()，和 getVertexAttrib() (en-US)
      this.gl.enableVertexAttribArray(polygonLocation);

      //告诉显卡从当前绑定的缓冲区（bindBuffer()指定的缓冲区）中读取顶点数据
      // 告诉属性怎么从positionBuffer中读取数据 (ARRAY_BUFFER)
      this.gl.vertexAttribPointer(polygonLocation, 2, this.gl.FLOAT, false, 0, 0);


      /*-----------纹理坐标------------*/

      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.texCoordBuffer);

      // 获取顶点位置的索引
      let texLocation = this.gl.getAttribLocation(this.shaderProgram, 'a_texCoord');
      // 激活每一个属性以便使用，不被激活的属性是不会被使用的。
      // 一旦激活，以下其他方法就可以获取到属性的值了，包括vertexAttribPointer()，vertexAttrib*()，和 getVertexAttrib() (en-US)
      this.gl.enableVertexAttribArray(texLocation);
      //告诉显卡从当前绑定的缓冲区（bindBuffer()指定的缓冲区）中读取顶点数据
      // 告诉属性怎么从positionBuffer中读取数据 (ARRAY_BUFFER)
      this.gl.vertexAttribPointer(texLocation,2,this.gl.FLOAT, false, 0, 0);


      //  多边形有2个三角形，每个三角形需要3个点，共6个点
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.texCoordBuffer);
      this.gl.drawArrays(this.gl.TRIANGLES, 0, 6);
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
      // 获取uMatrix在着色器程序中的位置
      let uMatrixLocation = this.gl.getUniformLocation(this.shaderProgram, 'u_matrix');
      // 设置uMatrix的值
      this.gl.uniformMatrix3fv(uMatrixLocation, false, this.uMatrix);
    },
    /**
     * 设置纹理坐标的缓冲数据
     */
    async setTexCoordBuffers() {

      let textCoord = [
        0.0,  0.0,
        1.0,  0.0,
        0.0,  1.0,

        0.0,  1.0,
        1.0,  0.0,
        1.0,  1.0
      ]

      // 创建纹理坐标的缓冲区
      this.texCoordBuffer = this.gl.createBuffer();
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.texCoordBuffer);
      // 把顶点数据发送到绑定的缓冲区
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(textCoord), this.gl.STATIC_DRAW);
    },
    /**
     * 设置多边形的缓冲数据（屏幕像素坐标）
     * @returns {Promise<void>}
     */
    async setPolygonBuffers() {

      // 多边形的顶点（两个三角形的顶点构成）
      let polygonVertex = [
        0.0, 0.0,
        200.0, 0.0,
        0.0, 200.0,

        0.0, 200.0,
        200.0, 0.0,
        200.0, 200.0
      ]

      // 创建多边形的缓冲区
      this.polygonVertexBuffer = this.gl.createBuffer();
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.polygonVertexBuffer);
      // 把顶点数据发送到绑定的缓冲区
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(polygonVertex), this.gl.STATIC_DRAW);
    },
    /**
     * 设置视口和画布
     * @returns {Promise<void>}
     */
    setupViewPort() {
      // 设置画布的显示尺寸和 画布的drawingbuffer尺寸相同
      resizeCanvasToDisplaySize(this.gl.canvas);
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
