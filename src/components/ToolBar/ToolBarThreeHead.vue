<template>
  <div class="operation-wrap">
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">领头羊角度</div></el-col>
      <el-col :span="16"><el-slider v-model="form.targetAngle" :min="-360" :max="360" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.targetAngle}}</div></el-col>
    </el-row>
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">领头羊高度</div></el-col>
      <el-col :span="16"><el-slider v-model="form.targetHeight" :min="-50" :max="300" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.targetHeight}}</div></el-col>
    </el-row>
  </div>
</template>

<script>
export default {
  name: "ToolBar",
  props:{

  },
  data() {
    return {
      form:{
        targetAngle: 0, // 领头羊角度
        targetHeight: 200, // 领头羊高度
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
