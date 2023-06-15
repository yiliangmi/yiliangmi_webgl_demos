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
      <ToolBar></ToolBar>
      <canvas ref="myCanvas" id="myCanvas" class="myCanvas">
      </canvas>
    </div>
  </div>
</template>

<script>
import ToolBar from "@/components/ToolBar/ToolBar.vue";
export default {
  name: "index",
  components: {ToolBar}
}
</script>

<style lang="scss" scoped>
.home-wrap {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
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
  width: 600px;
  height: 600px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.myCanvas {
  width: 600px;
  height: 600px;
  position: relative;
}

</style>
