<template>
  <div class="home-wrap">
    <div class="home_header">三维矩阵之跟随转动的头部模型</div>
    <div>
      <h4>tips</h4>
      <ul>
        <li>lookAt()用来生成视图变换矩阵（view）；targetTo()用来生成指向目标的模型矩阵(model)；</li>
        <li>MVPmatrix = projection * view * model；</li>
      </ul>
    </div>
    <div class="home-content">
      <ToolBarThreeHead @updateScene="updateScene"></ToolBarThreeHead>
      <canvas ref="myCanvas" id="myCanvas" class="myCanvas">
      </canvas>
    </div>
  </div>
</template>

<script>
import ToolBarThreeHead from "@/components/ToolBar/ToolBarThreeHead.vue";
import fShaderSource from './shaders/fShader.glsl';
import vShaderSource from './shaders/vShader.glsl';
import {resizeCanvasToDisplaySize} from "@/utils/myCommon";
import {vec4, mat4, glMatrix} from "gl-matrix";
import {HeadData} from './headdata/headdata.js'

export default {
  name: "index",
  components: {ToolBarThreeHead},
  data() {
    return{
      sliderBar: {
        targetAngle: 0, // 领头羊角度
        targetHeight: 0, // 领头羊高度
      },  // 滑块对象
      canvas: null, //canvas对象
      gl: null,  //webgl上下文,
      shaderProgram: null,  //着色器程序
      headVertexBuffer: null,  //头部顶点坐标缓冲区
      headColorBuffer: null,  //头部顶点颜色缓冲区
      uMatrix: mat4.create(),  //生成 mat4 单位矩阵
      targetRadius: 300,  // 领头羊旋转半径
      target: [0, 200, 300],          // 领头羊位置
      numElements: 0             //节点数量
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
        //设置头部的缓冲数据（屏幕像素坐标）
        await this.setHeadBuffers();
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
      let targetAngleRadians = glMatrix.toRadian(this.sliderBar.targetAngle);
      this.target[0] = Math.sin(targetAngleRadians) * this.targetRadius;  //x
      this.target[1] = this.sliderBar.targetHeight;                       //y
      this.target[2] = Math.cos(targetAngleRadians) * this.targetRadius;  //z

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

      // 循环绘制字母F
      await this.drawHeads();
    },
    /**
     * 循环绘制头部
     * @returns {Promise<void>}
     */
    async drawHeads() {
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

        // 在格网内生成羊群
        let deep = 5;
        let across = 5;
        for (let zz = 0; zz < deep; ++zz) {
          let v = zz / (deep - 1);
          let z = (v - .5) * deep * 150;
          for (let xx = 0; xx < across; ++xx) {
            let u = xx / (across - 1);
            let x = (u - .5) * across * 150;
            let matrix = mat4.create();
            mat4.targetTo(matrix, [x, 0, z], this.target, [0, 1, 0]);
            await this.drawHead(matrix, this.uMatrix, uMatrixLocation, this.numElements);
          }
        }
        // 绘制领头羊
        let matrix_h = mat4.create();
        mat4.translate(matrix_h, matrix_h, [this.target[0], this.target[1], this.target[2]])
        await this.drawHead(matrix_h, this.uMatrix, uMatrixLocation, this.numElements);

      }
    },
    /**
     * 绘制头部模型
     * @returns {Promise<void>}
     */
    async drawHead(matrix, viewProjectionMatrix, matrixLocation, numElements) {

      // 使用视图投影矩阵乘以模型矩阵
      let matrixFinal = mat4.create();
      matrixFinal = mat4.multiply(matrixFinal, viewProjectionMatrix, matrix);

      // 设置uMatrix的值
      this.gl.uniformMatrix4fv(matrixLocation, false, matrixFinal);

      /*-------------顶点位置-------------*/
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.headVertexBuffer);

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
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.headColorBuffer);
      // 获取颜色位置的索引
      let fColorLocation = this.gl.getAttribLocation(this.shaderProgram, 'a_color');
      // 激活每一个属性以便使用，不被激活的属性是不会被使用的。
      // 一旦激活，以下其他方法就可以获取到属性的值了，包括vertexAttribPointer()，vertexAttrib*()，和 getVertexAttrib() (en-US)
      this.gl.enableVertexAttribArray(fColorLocation);

      //告诉显卡从当前绑定的缓冲区（bindBuffer()指定的缓冲区）中读取顶点数据
      // 告诉属性怎么从positionBuffer中读取数据 (ARRAY_BUFFER)
      this.gl.vertexAttribPointer(fColorLocation, 3, this.gl.UNSIGNED_BYTE, true, 0, 0);

      //  'F'有6个三角形，每个三角形需要16个面，每个面六个顶点
      this.gl.drawArrays(this.gl.TRIANGLES, 0, numElements);
    },
    /**
     * 设置顶点的二维变换矩阵
     * @returns {Promise<void>}
     */
    async setUMatrix() {
      //设置  mat4 为单位矩阵
      this.uMatrix = mat4.create();
      // 按照投影矩阵*平移矩阵*旋转矩阵*缩放矩阵*顶点坐标进行空间变换

      /*-------------计算投影矩阵-------------*/
      // 1.设置透视投影矩阵
      let fovy = glMatrix.toRadian(60);
      let aspect = this.gl.canvas.clientWidth / this.gl.canvas.clientHeight;
      let near = 1;
      let far = 3000;
      let projectionMatrix = mat4.create();
      mat4.perspective(projectionMatrix, fovy, aspect, near, far);

      /*-------------计算视图矩阵-------------*/

      // 2、计算视图
      let cameraTarget = [0, 0, 0];
      let cameraPosition = [800, 300, 800];
      let up = [0, 1, 0];

      // 计算相机的朝向矩阵,根据相机矩阵创建视图矩阵--都在lookAt方法中完成
      let cameraLookMatrix = mat4.create();
      mat4.lookAt(cameraLookMatrix, cameraPosition, cameraTarget, up);

      // 3、计算视图投影矩阵
      this.uMatrix = mat4.multiply(this.uMatrix, projectionMatrix, cameraLookMatrix);

    },
    /**
     * 设置头部模型的缓冲数据（屏幕像素坐标）
     * @returns {Promise<void>}
     */
    async setHeadBuffers() {

      // 头部的顶点
      let headVertex = HeadData.positions;

      let matrix = mat4.create();

      let matrixYRotation = mat4.create();
      mat4.rotateY(matrixYRotation,matrixYRotation, Math.PI);

      let matrixScale = mat4.create();
      mat4.scale(matrixScale, matrixScale, [6, 6, 6]);

      matrix = mat4.multiply(matrix, matrixScale, matrixYRotation);

      for (let ii = 0; ii < headVertex.length; ii += 3) {
        let vector = vec4.create();
        vec4.transformMat4(vector, [headVertex[ii + 0], headVertex[ii + 1], headVertex[ii + 2], 1], matrix);
        headVertex[ii + 0] = vector[0];
        headVertex[ii + 1] = vector[1];
        headVertex[ii + 2] = vector[2];
      }

      this.numElements = headVertex.length / 3;

      // 创建头部节点的缓冲区
      this.headVertexBuffer = this.gl.createBuffer();
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.headVertexBuffer);
      // 把顶点数据发送到绑定的缓冲区
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(headVertex), this.gl.STATIC_DRAW);


      // 头部的颜色
      let normals = HeadData.normals;
      let colors = new Uint8Array(normals.length);
      let offset = 0;
      for (let ii = 0; ii < colors.length; ii += 3) {
        for (let jj = 0; jj < 3; ++jj) {
          colors[offset] = (normals[offset] * 0.5 + 0.5) * 255;
          ++offset;
        }
      }
      // 创建字母F的颜色缓冲区
      this.headColorBuffer = this.gl.createBuffer();
      // 告诉WebGL，从现在开始，这个缓冲对象就是它要使用的对象
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.headColorBuffer);
      // 把顶点数据发送到绑定的缓冲区(注意数据类型)
      this.gl.bufferData(this.gl.ARRAY_BUFFER, colors, this.gl.STATIC_DRAW);

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
