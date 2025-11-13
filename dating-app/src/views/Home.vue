<template>
  <div class="min-h-screen bg-gray-50">
    <!-- 导航栏 -->
    <nav class="bg-white shadow-sm border-b">
      <div class="max-w-6xl mx-auto px-4 py-3">
        <div class="flex justify-between items-center">
          <h1 class="text-2xl font-bold text-pink-500">💞 交友网站</h1>
          <div class="flex items-center space-x-4">
            <router-link to="/profile" class="text-gray-600 hover:text-pink-500">
              我的资料
            </router-link>
            <router-link to="/matches" class="text-gray-600 hover:text-pink-500">
              我的匹配
            </router-link>
            <button @click="handleLogout" class="text-gray-600 hover:text-pink-500">
              退出登录
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- 主要内容 -->
    <div class="max-w-6xl mx-auto px-4 py-8">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- 用户信息卡片 -->
        <div class="lg:col-span-1">
          <div class="bg-white rounded-lg shadow p-6">
            <div class="text-center mb-4">
              <img
                :src="userStore.profile?.avatar_url || 'https://via.placeholder.com/150'"
                alt="头像"
                class="w-24 h-24 rounded-full mx-auto mb-4 object-cover"
              />
              <h2 class="text-xl font-semibold">{{ userStore.profile?.nickname }}</h2>
              <p class="text-gray-600">{{ userStore.profile?.city }}</p>
            </div>
            
            <div class="space-y-2">
              <p><span class="font-medium">性别:</span> {{ formatGender(userStore.profile?.gender) }}</p>
              <p><span class="font-medium">年龄:</span> {{ formatAge(userStore.profile?.birthday) }}</p>
              <p><span class="font-medium">兴趣:</span> {{ formatInterests(userStore.profile?.interests) }}</p>
            </div>
            
            <router-link
              to="/profile"
              class="block w-full mt-4 bg-pink-500 text-white text-center py-2 px-4 rounded hover:bg-pink-600"
            >
              编辑资料
            </router-link>
          </div>
        </div>

        <!-- 推荐用户列表 -->
        <div class="lg:col-span-2">
          <h3 class="text-2xl font-bold mb-6">为你推荐</h3>
          
          <div v-if="matchStore.loading" class="text-center py-8">
            <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500"></div>
          </div>
          
          <div v-else-if="matchStore.potentialMatches.length === 0" class="text-center py-8 text-gray-500">
            <p>暂无推荐用户</p>
          </div>
          
          <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div
              v-for="user in matchStore.potentialMatches"
              :key="user.id"
              class="bg-white rounded-lg shadow hover:shadow-lg transition-shadow"
            >
              <div class="p-6">
                <div class="flex items-center mb-4">
                  <img
                    :src="user.avatar_url || 'https://via.placeholder.com/100'"
                    alt="头像"
                    class="w-16 h-16 rounded-full object-cover mr-4"
                  />
                  <div>
                    <h4 class="font-semibold">{{ user.nickname }}</h4>
                    <p class="text-gray-600 text-sm">{{ user.city }}</p>
                  </div>
                </div>
                
                <p class="text-gray-700 mb-4">{{ user.bio || '暂无个人介绍' }}</p>
                
                <div class="flex space-x-2">
                  <button
                    @click="handleLike(user.id)"
                    class="flex-1 bg-pink-500 text-white py-2 px-4 rounded hover:bg-pink-600 transition-colors"
                  >
                    喜欢 ❤️
                  </button>
                  <router-link
                    :to="`/user/${user.id}`"
                    class="px-4 py-2 border border-gray-300 rounded hover:bg-gray-50 transition-colors"
                  >
                    查看资料
                  </router-link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useMatchStore } from '@/stores/match'

const router = useRouter()
const userStore = useUserStore()
const matchStore = useMatchStore()

const handleLogout = async () => {
  await userStore.signOut()
  router.push('/login')
}

const handleLike = async (targetId: string) => {
  try {
    const isMatch = await matchStore.likeUser(targetId)
    if (isMatch) {
      alert('恭喜！你们互相喜欢了！')
    }
    // 重新加载推荐列表
    await matchStore.fetchPotentialMatches()
  } catch (error) {
    console.error('点赞失败:', error)
    alert('点赞失败，请重试')
  }
}

const formatGender = (gender: string | null) => {
  const genderMap = {
    male: '男',
    female: '女',
    other: '其他'
  }
  return gender ? genderMap[gender as keyof typeof genderMap] : '未知'
}

const formatAge = (birthday: string | null) => {
  if (!birthday) return '未知'
  const birthDate = new Date(birthday)
  const today = new Date()
  let age = today.getFullYear() - birthDate.getFullYear()
  const monthDiff = today.getMonth() - birthDate.getMonth()
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--
  }
  return age + '岁'
}

const formatInterests = (interests: any) => {
  if (!interests || !Array.isArray(interests)) return '暂无'
  return interests.join(', ')
}

onMounted(async () => {
  await userStore.fetchUser()
  await matchStore.fetchPotentialMatches()
})
</script>