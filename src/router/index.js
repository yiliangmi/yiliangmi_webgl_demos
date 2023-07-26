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
        {
            path: '/demo001',
            name: 'demo001利用裁剪坐标（坐标范围是 -1 到 +1）绘制简单的三角形',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo001/index.vue')
        },
        {
            path: '/demo002',
            name: 'demo002利用屏幕像素坐标(左上角为坐标原点)绘制简单的三角形',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo002/index.vue')
        },
        {
            path: '/demo003',
            name: 'demo003利用屏幕像素坐标(左上角为坐标原点)随机绘制30个三角形',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo003/index.vue')
        },
        {
            path: '/demo004',
            name: 'demo004二维矩阵之绕原点旋转的F字母',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo004/index.vue')
        },
        {
            path: '/demo005',
            name: 'demo005二维矩阵之绕自定义中心点旋转的F字母',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo005/index.vue')
        },
        {
            path: '/demo006',
            name: 'demo006简单的纹理',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo006/index.vue')
        },
        {
            path: '/demo007',
            name: 'demo007平面绘制透视纹理校正',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo007/index.vue')
        },
        {
            path: '/demo008',
            name: 'demo008平面绘制透视视频纹理校正',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo008/index.vue')
        },
        {
            path: '/demo009',
            name: 'demo009使用卷积核处理图像纹理',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo009/index.vue')
        },
        {
            path: '/demo010',
            name: 'demo010图像纹理同时施加多种效果(帧缓冲)',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo010/index.vue')
        },
        {
            path: '/demo011',
            name: 'demo011使用多个纹理',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo011/index.vue')
        },
        {
            path: '/demo012',
            name: 'demo012三维矩阵之正射投影下的F字母',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo012/index.vue')
        },
        {
            path: '/demo013',
            name: 'demo013三维矩阵之透视投影下的F字母',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo013/index.vue')
        },
        {
            path: '/demo014',
            name: 'demo014三维矩阵之一个绕F旋转的相机',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo014/index.vue')
        },
        {
            path: '/demo015',
            name: 'demo015三维矩阵之总是看向特定的F且相机又在绕一圈F旋转的相机',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo015/index.vue')
        },
        {
            path: '/demo016',
            name: 'demo016三维矩阵之跟随转动的头部模型',
            meta:{
                isDemo: true
            },
            component: () => import('@/views/demo016/index.vue')
        },
    ]
  }
]

const router = new VueRouter({
  routes
})

export default router
