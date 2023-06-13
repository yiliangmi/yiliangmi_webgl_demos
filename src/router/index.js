import Vue from 'vue'
import VueRouter from 'vue-router'
import HomeView from '../views/HomeView.vue'
import ParentView from "@/components/ParentView/index.vue";

// 获取原型对象push函数
const originalPush = VueRouter.prototype.push

// 获取原型对象replace函数
const originalReplace = VueRouter.prototype.replace

// 修改原型对象中的push函数
VueRouter.prototype.push = function push(location){
    return originalPush.call(this , location).catch(err=>err)
}

// 修改原型对象中的replace函数
VueRouter.prototype.replace = function replace(location){
    return originalReplace.call(this , location).catch(err=>err)
}

Vue.use(VueRouter)

const routes = [
  {
    path: '/home',
    name: '首页',
    redirect:'/demoList',
    component: HomeView,
    children: [
        {
            path: '/demoList',
            name: '示例列表',
            component: () => import('@/views/demoList/index.vue')
        },
        {
            path: '/demo000',
            name: '000绘制简单的多边形',
            meta:{
              isDemo: true
            },
            component: () => import('@/views/demo000/index.vue')
        },
    ]
  }
]

const router = new VueRouter({
  routes
})

export default router
