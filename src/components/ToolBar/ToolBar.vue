<template>
  <div class="operation-wrap">
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">x轴平移</div></el-col>
      <el-col :span="16"><el-slider v-model="form.xVal" :min="0" :max="xMax" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.xVal}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">y轴平移</div></el-col>
      <el-col :span="16"><el-slider v-model="form.yVal" :min="0" :max="yMax" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.yVal}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">旋转角度</div></el-col>
      <el-col :span="16"><el-slider v-model="form.angleVal" :min="0" :max="360" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.angleVal}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">x轴方向缩放</div></el-col>
      <el-col :span="16"><el-slider v-model="form.scaleXVal" :min="-5" :max="5" :step="0.01" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.scaleXVal}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">y轴方向缩放</div></el-col>
      <el-col :span="16"><el-slider v-model="form.scaleYVal" :min="-5" :max="5" :step="0.01" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.scaleYVal}}</div></el-col>
    </el-row>
  </div>
</template>

<script>
export default {
  name: "ToolBar",
  props:{
    xMax:{
      type: Number,
      default: 100
    },
    yMax:{
      type: Number,
      default: 100
    },
  },
  data() {
    return {
      form:{
        xVal: 0, // x轴平移
        yVal: 0, // y轴平移
        angleVal: 0, // 旋转角度
        scaleXVal: 1, // x轴方向缩放
        scaleYVal: 1, // y轴方向缩放
      }
    }
  },
  methods:{
    handleInput(val) {
      this.$emit('updateScene', this.form)
    },
  }
}
</script>

<style lang="scss" scoped>
.operation-wrap {
  width: 600px;
  position: relative;
  .operation-item {
    width: 100%;
    height: 30px;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    flex-direction: row;
  }
}
</style>
