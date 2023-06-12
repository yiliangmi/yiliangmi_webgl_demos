<template>
    <div class="home-wrap">
      <div class="bread-crumb">
        <el-breadcrumb separator="/">
          <template v-for="(item, index) in breadList">
            <el-breadcrumb-item
                :key="index"
                :to="item.path"
            >
              {{ item.name }}
            </el-breadcrumb-item>
          </template>
        </el-breadcrumb>
      </div>
      <div class="home-content">
        <router-view></router-view>
      </div>
    </div>
</template>
<script>
export default {
  watch: {
    $route: {
      handler: function(val, oldVal){
        this.breadList = val.matched;
      },
      // 深度观察监听
      deep: true,
      immediate: true
    }
  },
  data() {
    return {
      breadList: []
    }
  },
  methods:{

  },
  mounted() {

  }
}
</script>
<style scoped lang="scss">
  .home-wrap {
    width: 100%;
    height: 100%;
    .bread-crumb {
      height: 80px;
      width: 100%;
      display: flex;
      align-items: center;
      justify-content: flex-start;
      background: #f3f3f3;
      font-weight: bold;
      padding-left: 20px;
      box-sizing: border-box;
    }
    .home-content {
      height: calc(100% - 80px);
      width: 100%;
      overflow: auto;
    }
  }

</style>
