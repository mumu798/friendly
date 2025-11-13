import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('../views/Home.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/Login.vue')
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('../views/Register.vue')
    },
    {
      path: '/profile',
      name: 'profile',
      component: () => import('../views/Profile.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/matches',
      name: 'matches',
      component: () => import('../views/Matches.vue'),
      meta: { requiresAuth: true }
    }
  ],
})

// 路由守卫
router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()
  
  // 检查是否需要认证
  if (to.meta.requiresAuth) {
    // 等待用户状态加载完成
    if (!userStore.isAuthenticated && !userStore.loading) {
      await userStore.fetchUser()
    }
    
    if (!userStore.isAuthenticated) {
      next('/login')
    } else {
      next()
    }
  } else {
    // 对于登录/注册页面，如果已登录则重定向到首页
    if ((to.path === '/login' || to.path === '/register') && userStore.isAuthenticated) {
      next('/')
    } else {
      next()
    }
  }
})

export default router
