<template>
  <div class="home-wrap">
    <div class="home_header">图像纹理同时施加多种效果(帧缓冲FBO)</div>
    <div>
      <h4>tips</h4>
      <ul>
        <li>渲染纹理时需要纹理坐标，而不是像素坐标</li>
        <li>由于WebGL的纹理坐标范围是 0.0 到 1.0 ， 那我们可以简单计算出移动一个像素对应的距离， onePixel = 1.0 / textureSize</li>
        <li>我们将使用 3×3 的内核，卷积内核就是一个 3×3 的矩阵， 矩阵中的每一项代表当前处理的像素和周围8个像素的乘法因子， 相乘后将结果加起来除以内核权重（内核中所有值的和或 1.0 ，取二者中较大者）</li>
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
      originalImageTexture: null,  //原始纹理
      uMatrix: mat3.create(),  //生成 mat3 单位矩阵
      textures: [],  // 纹理数组
      framebuffers: [],  // 帧缓冲数组
      kernels: {     //定义一些卷积核
        normal: [
          0, 0, 0,
          0, 1, 0,
          0, 0, 0
        ],
        gaussianBlur: [
          0.045, 0.122, 0.045,
          0.122, 0.332, 0.122,
          0.045, 0.122, 0.045
        ],
        unsharpen: [
          -1, -1, -1,
          -1,  9, -1,
          -1, -1, -1
        ],
        emboss: [
          -2, -1,  0,
          -1,  1,  1,
          0,  1,  2
        ]
      },
      effects: [   // 将要使用的效果列表
          'emboss','emboss','emboss'
      ],
      image: null
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

      // 设置纹理
      // 图片是异步加载的，所以我们需要等待纹理加载，一旦加载完成就开始绘制
      await this.setupTextures();

      //设置多边形的缓冲数据（屏幕像素坐标）
      await this.setPolygonBuffers();
      // 设置纹理坐标的缓冲数据
      await this.setTexCoordBuffers();

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
        this.image = new Image();
        this.image.src = require('./textures/test.png')
        this.image.onload = async () => {

          //创建一个原始纹理
          this.originalImageTexture = await this.handleTextureLoaded();
          this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, this.gl.RGBA, this.gl.UNSIGNED_BYTE, this.image);

          // 创建两个纹理，绑定到帧缓冲中
          await this.bindTexturesToFramebuffers(this.image);
          resolve(true);
        }
      }))

    },
    /**
     * 创建两个纹理绑定到帧缓冲
     */
    async bindTexturesToFramebuffers(image) {
      for (let i = 0; i < 2; i++) {
        // 创建纹理，存放到数组内
        let texture = await this.handleTextureLoaded();
        this.textures.push(texture);

        // 设置纹理大小和图像大小一致
        this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, image.width, image.height, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, null);

        //创建第一个帧缓冲
        let fbo = this.gl.createFramebuffer();
        this.framebuffers.push(fbo);
        this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, fbo);

        //绑定纹理到帧缓冲
        this.gl.framebufferTexture2D(this.gl.FRAMEBUFFER, this.gl.COLOR_ATTACHMENT0, this.gl.TEXTURE_2D, texture, 0);
      }
    },
    /**
     * 图片加载后上传至纹理
     * @param image
     * @param texture
     * @returns {Promise<void>}
     */
    async handleTextureLoaded() {
      let texture = this.gl.createTexture();
      //通过把新创建的纹理对象绑定到 gl.TEXTURE_2D 来让它成为当前操作纹理
      this.gl.bindTexture(this.gl.TEXTURE_2D, texture);

      //如果效果列表为奇数次循环，对纹理图像进行y轴反转（偶数次时，y轴反转抵消）
      if (this.effects.length % 2 === 1) {
        this.gl.pixelStorei(this.gl.UNPACK_FLIP_Y_WEBGL,true);
      }

      // 设置参数，让我们可以绘制任何尺寸的图像
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_S, this.gl.CLAMP_TO_EDGE);
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_T, this.gl.CLAMP_TO_EDGE);
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MIN_FILTER, this.gl.NEAREST);
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MAG_FILTER, this.gl.NEAREST);

      return texture;
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


      /*---------施加多种效果----------*/
      let textureSizeLocation = this.gl.getUniformLocation(this.shaderProgram, "u_textureSize");
      this.gl.uniform2f(textureSizeLocation, this.image.width, this.image.height);

      // 从原始图像开始
      this.gl.bindTexture(this.gl.TEXTURE_2D, this.originalImageTexture);

      // 循环施加每一种渲染效果
      for (let i = 0; i < this.effects.length; i++) {
        // 使用两个帧缓冲中的一个
        await this.setFramebuffer(this.framebuffers[i % 2], this.image.width, this.image.height);

        // 添加卷积核效果
        this.drawWithKernel(this.effects[i]);

        // 下次绘制时使用刚才的渲染结果
        this.gl.bindTexture(this.gl.TEXTURE_2D, this.textures[i % 2]);

      }

      // 最后将结果绘制到画布
      //调用 gl.bindFramebuffer 设置为 null是告诉WebGL 你想在画布上绘制，而不是在帧缓冲上
      await this.setFramebuffer(null, this.gl.canvas.clientWidth, this.gl.canvas.clientHeight);
      this.drawWithKernel("normal");

    },
    drawWithKernel(name) {
      // 设置卷积核
      let kernelLocation = this.gl.getUniformLocation(this.shaderProgram, "u_kernel");
      let kernelWeightLocation = this.gl.getUniformLocation(this.shaderProgram, "u_kernelWeight");

      this.gl.uniform1fv(kernelLocation, this.kernels[name]);
      this.gl.uniform1f(kernelWeightLocation, this.computeKernelWeight(this.kernels[name]));

      // 画出矩形
      this.gl.drawArrays(this.gl.TRIANGLES, 0, 6);
    },
    async setFramebuffer(fbo, width, height) {
      // 设定当前使用帧缓冲
      this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, fbo);

      await this.setUMatrix(width, height);

      //告诉WebGL帧缓冲需要的视图大小
      this.gl.viewport(0, 0, width, height);
    },
    /**
     * 设置顶点的二维变换矩阵
     * @returns {Promise<void>}
     */
    async setUMatrix(width, height) {
      this.uMatrix = mat3.create();
      //设置  mat3 为单位矩阵
      this.uMatrix = mat3.identity(this.uMatrix);
      // 按照投影矩阵*平移矩阵*旋转矩阵*缩放矩阵*顶点坐标进行空间变换
      // 1.把屏幕像素坐标（左上角为坐标原点）转换为裁剪坐标（坐标范围是 -1 到 +1）
      this.uMatrix = mat3.projection(this.uMatrix, width, height);
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
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,

        0.0, 1.0,
        1.0, 0.0,
        1.0, 1.0
      ]

      // 创建纹理坐标的缓冲区
      this.texCoordBuffer = this.gl.createBuffer();
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.texCoordBuffer);
      // 把顶点数据发送到绑定的缓冲区
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(textCoord), this.gl.STATIC_DRAW);


    },
    computeKernelWeight(kernel) {
      let weight = kernel.reduce(function(prev, curr) {
        return prev + curr;
      });
      return weight <= 0 ? 1 : weight;
    },
    /**
     * 设置多边形的缓冲数据（屏幕像素坐标）
     * @returns {Promise<void>}
     */
    async setPolygonBuffers() {

      let x1 = 0;
      let x2 = this.image.width;
      let y1 = 0;
      let y2 = this.image.height;

      // 多边形的顶点（两个三角形的顶点构成）
      // 未变形的顶点
      let polygonVertex = [
        x1, y1,
        x2, y1,
        x1, y2,

        x1, y2,
        x2, y1,
        x2, y2,
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
      //this.gl.viewport(0, 0, this.gl.canvas.width, this.gl.canvas.height);
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
  background: #1e28da;
}

</style>
