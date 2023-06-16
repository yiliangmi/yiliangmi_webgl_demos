<template>
  <div class="demo-wrap">
    <template v-for="(item, index) in breadList">
      <div
          class="demo-item"
          :key="index"
          @click="goDemo(item.path)"
      >
        {{ item.name }}
      </div>
    </template>
  </div>

</template>

<script>
export default {
  name: "index",
  data() {
    return {
      breadList: []
    }
  },
  methods:{
    //过滤
    getBreadCrumbList() {
      this.breadList = this.$router.options.routes[0].children.filter((item, index) => {
        return item.meta && item.meta.isDemo
      })
    },
    goDemo(path) {
      this.$router.push(path);
    },
  },
  mounted() {
    this.$nextTick(() => {
      this.getBreadCrumbList()
    })
  }
}
</script>

<style lang="scss" scoped>
.demo-wrap {
  width: 100%;
  height: 100%;
  overflow: auto;
  .demo-item {
    height: 40px;
    width: 100%;
    font-size: 18px;
    display: flex;
    align-items: center;
    box-sizing: border-box;
    border-bottom: 1px solid #c3c6cb;
    padding-left: 20px;
    cursor: pointer;
    &:hover{
      background: #c3c6cb;
    }
  }
}
</style>
