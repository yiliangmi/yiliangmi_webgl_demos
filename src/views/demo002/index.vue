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
export default {
  name: "index",
  mounted() {
    let self = this;
    self.$nextTick(async () => {
      await self.init();
    })
  },
  data() {
    return {
      canvas: null, //canvas对象
      gl: null, //webgl上下文
    }
  },
  methods: {
    //初始化程序
    async init() {
      //获取webgl上下文
      let isGlExist = await this.getGl();
    },
    /**
     * 获取webgl上下文
     */
    getGl() {
      this.canvas = this.$refs.myCanvas;
      this.gl = this.canvas.getContext('webgl') || this.canvas.getContext('experimental-webgl');

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
