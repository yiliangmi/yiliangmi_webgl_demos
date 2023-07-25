<template>
  <div class="operation-wrap">
    <el-row :gutter="20" class="operation-item">
      <el-col :span="4"><div class="demonstration">相机角度</div></el-col>
      <el-col :span="16"><el-slider v-model="form.cameraAngle" :min="-360" :max="360" @input="handleInput"></el-slider></el-col>
      <el-col :span="4"><div class="demonstration">{{form.cameraAngle}}</div></el-col>
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
        cameraAngle: 0, // 相机角度
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
