<template>
  <div class="home-wrap">
    <div class="home_header">三维矩阵之一个绕F旋转的相机</div>
    <div>
      <h4>tips</h4>
      <ul>
        <li>一旦有了相机从原点移动旋转到目标位置的矩阵后， 就可以计算出它的逆矩阵，利用这个逆矩阵可以不动相机，将物体从相反的方向移动到相机前。</li>
        <li>相机：看向原点，在半径为 radius * 1.5 的圆上移动的相机</li>
        <li>我们可以使用 inverse 方法计算逆矩阵（ 完全对立的转换矩阵），在这个例子中提供的是绕原点转动的矩阵， 它的逆矩阵是移动相机以外的所有物体，好像相机在原点一样</li>
      </ul>
    </div>
    <div class="home-content">
      <ToolBarThreeCamera @updateScene="updateScene"></ToolBarThreeCamera>
      <canvas ref="myCanvas" id="myCanvas" class="myCanvas">
      </canvas>
    </div>
  </div>
</template>

<script>
import ToolBarThreeCamera from "@/components/ToolBar/ToolBarThreeCamera.vue";
import fShaderSource from './shaders/fShader.glsl';
import vShaderSource from './shaders/vShader.glsl';
import {resizeCanvasToDisplaySize} from "@/utils/myCommon";
import {vec4, mat4, glMatrix} from "gl-matrix";

export default {
  name: "index",
  components: {ToolBarThreeCamera},
  data() {
    return{
      sliderBar: {
        cameraAngle: 0, // 相机角度
      },  // 滑块对象
      canvas: null, //canvas对象
      gl: null,  //webgl上下文,
      shaderProgram: null,  //着色器程序
      fVertexBuffer: null,  //字母f顶点坐标缓冲区
      fColorBuffer: null,  //字母f顶点颜色缓冲区
      uMatrix: mat4.create(),  //生成 mat4 单位矩阵
      radius: 200
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
      // 设置顶点的三维变换矩阵
      await this.setUMatrix();
      //设置字母F的缓冲数据（屏幕像素坐标）
      await this.setFBuffers();
      // 循环绘制字母F
      await this.drawFs();
    },
    /**
     * 循环绘制F
     * @returns {Promise<void>}
     */
    async drawFs() {
      let numFs = 5;
      for (let i = 0; i < numFs; i++) {
         let angle = i * Math.PI * 2 / numFs;
         let x = Math.cos(angle) * this.radius;
         let z = Math.sin(angle) * this.radius;

        // 从视图投影矩阵开始
        // 计算 F 的矩阵
        let matrix = mat4.create();
        mat4.translate(matrix, this.uMatrix, [x, 0, z]);

        //设置矩阵
        // 获取uMatrix在着色器程序中的位置
        let uMatrixLocation = this.gl.getUniformLocation(this.shaderProgram, 'u_matrix');
        // 设置uMatrix的值
        this.gl.uniformMatrix4fv(uMatrixLocation, false, matrix);

        // 绘制字母F
        await this.drawF();

      }
    },
    /**
     * 绘制字母F
     * @returns {Promise<void>}
     */
    async drawF() {

      /*-------------顶点位置-------------*/
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.fVertexBuffer);

      // 获取顶点位置的索引
      let fLocation = this.gl.getAttribLocation(this.shaderProgram, 'a_position');

      // 激活每一个属性以便使用，不被激活的属性是不会被使用的。
      // 一旦激活，以下其他方法就可以获取到属性的值了，包括vertexAttribPointer()，vertexAttrib*()，和 getVertexAttrib() (en-US)
      this.gl.enableVertexAttribArray(fLocation);

      //告诉显卡从当前绑定的缓冲区（bindBuffer()指定的缓冲区）中读取顶点数据
      // 告诉属性怎么从positionBuffer中读取数据 (ARRAY_BUFFER)
      this.gl.vertexAttribPointer(fLocation, 3, this.gl.FLOAT, false, 0, 0);

      /*-------------顶点颜色-------------*/
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.fColorBuffer);
      // 获取颜色位置的索引
      let fColorLocation = this.gl.getAttribLocation(this.shaderProgram, 'a_color');
      // 激活每一个属性以便使用，不被激活的属性是不会被使用的。
      // 一旦激活，以下其他方法就可以获取到属性的值了，包括vertexAttribPointer()，vertexAttrib*()，和 getVertexAttrib() (en-US)
      this.gl.enableVertexAttribArray(fColorLocation);

      //告诉显卡从当前绑定的缓冲区（bindBuffer()指定的缓冲区）中读取顶点数据
      // 告诉属性怎么从positionBuffer中读取数据 (ARRAY_BUFFER)
      this.gl.vertexAttribPointer(fColorLocation, 3, this.gl.UNSIGNED_BYTE, true, 0, 0);

      //  'F'有6个三角形，每个三角形需要16个面，每个面六个顶点
      this.gl.drawArrays(this.gl.TRIANGLES, 0, 16*6);
    },
    /**
     * 设置顶点的二维变换矩阵
     * @returns {Promise<void>}
     */
    async setUMatrix() {
      //设置  mat4 为单位矩阵
      this.uMatrix = mat4.create();
      // 按照投影矩阵*平移矩阵*旋转矩阵*缩放矩阵*顶点坐标进行空间变换
      // 1.设置透视投影矩阵
      let fovy = glMatrix.toRadian(60);
      let aspect = this.gl.canvas.clientWidth / this.gl.canvas.clientHeight;
      let near = 1;
      let far = 2000;
      let projectionMatrix = mat4.create();
      mat4.perspective(projectionMatrix, fovy, aspect, near, far);

      // 2、计算相机矩阵
      let cameraMatrix = mat4.create();
      cameraMatrix = mat4.rotateY(cameraMatrix, cameraMatrix, glMatrix.toRadian(this.sliderBar.cameraAngle));
      cameraMatrix = mat4.translate(cameraMatrix, cameraMatrix, [0, 0, this.radius * 1.5]);

      // 3、根据相机矩阵创建视图矩阵(逆矩阵)
      let viewMatrix = mat4.create();
      viewMatrix = mat4.invert(viewMatrix, cameraMatrix);


      // 4、计算视图投影矩阵
      this.uMatrix = mat4.multiply(this.uMatrix, projectionMatrix, viewMatrix);

    },
    /**
     * 设置字母F的缓冲数据（屏幕像素坐标）
     * @returns {Promise<void>}
     */
    async setFBuffers() {

      // 字母F的顶点
      let fVertex = [
        // left column front
        0,   0,  0,
        0, 150,  0,
        30,   0,  0,
        0, 150,  0,
        30, 150,  0,
        30,   0,  0,

        // top rung front
        30,   0,  0,
        30,  30,  0,
        100,   0,  0,
        30,  30,  0,
        100,  30,  0,
        100,   0,  0,

        // middle rung front
        30,  60,  0,
        30,  90,  0,
        67,  60,  0,
        30,  90,  0,
        67,  90,  0,
        67,  60,  0,

        // left column back
        0,   0,  30,
        30,   0,  30,
        0, 150,  30,
        0, 150,  30,
        30,   0,  30,
        30, 150,  30,

        // top rung back
        30,   0,  30,
        100,   0,  30,
        30,  30,  30,
        30,  30,  30,
        100,   0,  30,
        100,  30,  30,

        // middle rung back
        30,  60,  30,
        67,  60,  30,
        30,  90,  30,
        30,  90,  30,
        67,  60,  30,
        67,  90,  30,

        // top
        0,   0,   0,
        100,   0,   0,
        100,   0,  30,
        0,   0,   0,
        100,   0,  30,
        0,   0,  30,

        // top rung right
        100,   0,   0,
        100,  30,   0,
        100,  30,  30,
        100,   0,   0,
        100,  30,  30,
        100,   0,  30,

        // under top rung
        30,   30,   0,
        30,   30,  30,
        100,  30,  30,
        30,   30,   0,
        100,  30,  30,
        100,  30,   0,

        // between top rung and middle
        30,   30,   0,
        30,   60,  30,
        30,   30,  30,
        30,   30,   0,
        30,   60,   0,
        30,   60,  30,

        // top of middle rung
        30,   60,   0,
        67,   60,  30,
        30,   60,  30,
        30,   60,   0,
        67,   60,   0,
        67,   60,  30,

        // right of middle rung
        67,   60,   0,
        67,   90,  30,
        67,   60,  30,
        67,   60,   0,
        67,   90,   0,
        67,   90,  30,

        // bottom of middle rung.
        30,   90,   0,
        30,   90,  30,
        67,   90,  30,
        30,   90,   0,
        67,   90,  30,
        67,   90,   0,

        // right of bottom
        30,   90,   0,
        30,  150,  30,
        30,   90,  30,
        30,   90,   0,
        30,  150,   0,
        30,  150,  30,

        // bottom
        0,   150,   0,
        0,   150,  30,
        30,  150,  30,
        0,   150,   0,
        30,  150,  30,
        30,  150,   0,

        // left side
        0,   0,   0,
        0,   0,  30,
        0, 150,  30,
        0,   0,   0,
        0, 150,  30,
        0, 150,   0];

      var matrix = mat4.create();
      mat4.rotateX(matrix,matrix, Math.PI);
      matrix = mat4.translate(matrix, matrix, [-50, -75, -15]);

      for (var ii = 0; ii < fVertex.length; ii += 3) {
        let vector = vec4.create();
        vec4.transformMat4(vector, [fVertex[ii + 0], fVertex[ii + 1], fVertex[ii + 2], 1], matrix);
        fVertex[ii + 0] = vector[0];
        fVertex[ii + 1] = vector[1];
        fVertex[ii + 2] = vector[2];
      }

      // 创建字母F的缓冲区
      this.fVertexBuffer = this.gl.createBuffer();
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.fVertexBuffer);
      // 把顶点数据发送到绑定的缓冲区
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(fVertex), this.gl.STATIC_DRAW);


      // 字母F的颜色
      let fColor = [
        // left column front
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,

        // top rung front
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,

        // middle rung front
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,
        200, 70, 120,

        // left column back
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,

        // top rung back
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,

        // middle rung back
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,
        80, 70, 200,

        // top
        70, 200, 210,
        70, 200, 210,
        70, 200, 210,
        70, 200, 210,
        70, 200, 210,
        70, 200, 210,

        // top rung right
        200, 200, 70,
        200, 200, 70,
        200, 200, 70,
        200, 200, 70,
        200, 200, 70,
        200, 200, 70,

        // under top rung
        210, 100, 70,
        210, 100, 70,
        210, 100, 70,
        210, 100, 70,
        210, 100, 70,
        210, 100, 70,

        // between top rung and middle
        210, 160, 70,
        210, 160, 70,
        210, 160, 70,
        210, 160, 70,
        210, 160, 70,
        210, 160, 70,

        // top of middle rung
        70, 180, 210,
        70, 180, 210,
        70, 180, 210,
        70, 180, 210,
        70, 180, 210,
        70, 180, 210,

        // right of middle rung
        100, 70, 210,
        100, 70, 210,
        100, 70, 210,
        100, 70, 210,
        100, 70, 210,
        100, 70, 210,

        // bottom of middle rung.
        76, 210, 100,
        76, 210, 100,
        76, 210, 100,
        76, 210, 100,
        76, 210, 100,
        76, 210, 100,

        // right of bottom
        140, 210, 80,
        140, 210, 80,
        140, 210, 80,
        140, 210, 80,
        140, 210, 80,
        140, 210, 80,

        // bottom
        90, 130, 110,
        90, 130, 110,
        90, 130, 110,
        90, 130, 110,
        90, 130, 110,
        90, 130, 110,

        // left side
        160, 160, 220,
        160, 160, 220,
        160, 160, 220,
        160, 160, 220,
        160, 160, 220,
        160, 160, 220
      ]
      // 创建字母F的颜色缓冲区
      this.fColorBuffer = this.gl.createBuffer();
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.fColorBuffer);
      // 把顶点数据发送到绑定的缓冲区(注意数据类型)
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Uint8Array(fColor), this.gl.STATIC_DRAW);

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
      // 清除画布和深度缓冲
      this.gl.clear(this.gl.COLOR_BUFFER_BIT || this.gl.DEPTH_BUFFER_BIT);
      // 开启面剔除，开启这个特性后WebGL默认“剔除”背面三角形
      this.gl.enable(this.gl.CULL_FACE);

      // 开启深度缓冲
      this.gl.enable(this.gl.DEPTH_TEST);

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
