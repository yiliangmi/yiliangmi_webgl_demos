<template>
  <div class="operation-wrap">
   <!-- <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">垂直视角</div></el-col>
      <el-col :span="16"><el-slider v-model="form.fieldOfView" :min="1" :max="179" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.fieldOfView}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">近截面</div></el-col>
      <el-col :span="16"><el-slider v-model="form.near" :min="1" :max="2000" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.near}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">远截面</div></el-col>
      <el-col :span="16"><el-slider v-model="form.far" :min="1" :max="2000" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.far}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">x轴平移</div></el-col>
      <el-col :span="16"><el-slider v-model="form.xVal" :min="-200" :max="xMax" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.xVal}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">y轴平移</div></el-col>
      <el-col :span="16"><el-slider v-model="form.yVal" :min="-200" :max="yMax" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.yVal}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">z轴平移</div></el-col>
      <el-col :span="16"><el-slider v-model="form.zVal" :min="-1000" :max="zMax" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.zVal}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">绕x轴旋转</div></el-col>
      <el-col :span="16"><el-slider v-model="form.angleXVal" :min="0" :max="360" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.angleXVal}}</div></el-col>
    </el-row>-->
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">绕y轴旋转</div></el-col>
      <el-col :span="16"><el-slider v-model="form.angleYVal" :min="0" :max="360" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.angleYVal}}</div></el-col>
    </el-row>
   <!-- <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">绕z轴旋转</div></el-col>
      <el-col :span="16"><el-slider v-model="form.angleZVal" :min="0" :max="360" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.angleZVal}}</div></el-col>
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
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">z轴方向缩放</div></el-col>
      <el-col :span="16"><el-slider v-model="form.scaleZVal" :min="-5" :max="5" :step="0.01" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.scaleZVal}}</div></el-col>
    </el-row>-->
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
    zMax:{
      type: Number,
      default: 100
    },
  },
  data() {
    return {
      form:{
        fieldOfView: 30, // 垂直视角
        near: 1, // 近截面
        far: 2000, // 远截面
        xVal: 0, // x轴平移
        yVal: 0, // y轴平移
        zVal: 0, // z轴平移
        angleXVal: 0, // x轴旋转角度
        angleYVal: 0, // y轴旋转角度
        angleZVal: 0, // z轴旋转角度
        scaleXVal: 1, // x轴方向缩放
        scaleYVal: 1, // y轴方向缩放
        scaleZVal: 1, // z轴方向缩放
      }
    }
  },
  methods:{
    handleInput(val, flag) {
      this.$emit('updateScene', this.form);
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
