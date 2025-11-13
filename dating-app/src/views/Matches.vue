<template>
  <div class="min-h-screen bg-gray-50">
    <!-- 导航栏 -->
    <nav class="bg-white shadow-sm border-b">
      <div class="max-w-6xl mx-auto px-4 py-3">
        <div class="flex justify-between items-center">
          <h1 class="text-2xl font-bold text-pink-500">💞 交友网站</h1>
          <div class="flex items-center space-x-4">
            <router-link to="/" class="text-gray-600 hover:text-pink-500">
              首页
            </router-link>
            <router-link to="/profile" class="text-gray-600 hover:text-pink-500">
              我的资料
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
      <h2 class="text-2xl font-bold mb-6">我的匹配</h2>
      
      <div v-if="matchStore.loading" class="text-center py-8">
        <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500"></div>
      </div>
      
      <div v-else-if="matchStore.matches.length === 0" class="text-center py-8 text-gray-500">
        <p>还没有匹配的用户，快去首页看看吧！</p>
      </div>
      
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="match in matchStore.matches"
          :key="match.id"
          class="bg-white rounded-lg shadow hover:shadow-lg transition-shadow"
        >
          <div class="p-6">
            <div class="flex items-center mb-4">
              <img
                :src="getMatchAvatar(match) || 'https://via.placeholder.com/100'"
                alt="头像"
                class="w-16 h-16 rounded-full object-cover mr-4"
              />
              <div>
                <h4 class="font-semibold">{{ getMatchNickname(match) }}</h4>
                <p class="text-gray-600 text-sm">{{ getMatchCity(match) }}</p>
                <p class="text-gray-500 text-xs">{{ formatMatchTime(match.created_at) }}</p>
              </div>
            </div>
            
            <p class="text-gray-700 mb-4">{{ getMatchBio(match) || '暂无个人介绍' }}</p>
            
            <div class="flex space-x-2">
              <router-link
                :to="`/chat/${getMatchId(match)}`"
                class="flex-1 bg-pink-500 text-white py-2 px-4 rounded hover:bg-pink-600 transition-colors text-center"
              >
                发送消息 💬
              </router-link>
              <router-link
                :to="`/user/${getMatchId(match)}`"
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
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useMatchStore } from '@/stores/match'
import type { Tables } from '@/lib/types'

const router = useRouter()
const userStore = useUserStore()
const matchStore = useMatchStore()

const handleLogout = async () => {
  await userStore.signOut()
  router.push('/login')
}

const getMatchId = (match: Tables<'matches'>) => {
  const currentUserId = userStore.user?.id
  return match.user_a === currentUserId ? match.user_b : match.user_a
}

const getMatchProfile = (match: Tables<'matches'>) => {
  const matchId = getMatchId(match)
  // 这里需要根据实际需求调整，可能需要额外的查询
  return null
}

const getMatchAvatar = (match: Tables<'matches'>) => {
  // 这里需要根据实际需求实现，可能需要额外的查询
  return null
}

const getMatchNickname = (match: Tables<'matches'>) => {
  // 这里需要根据实际需求实现，可能需要额外的查询
  return '用户'
}

const getMatchCity = (match: Tables<'matches'>) => {
  // 这里需要根据实际需求实现，可能需要额外的查询
  return '未知城市'
}

const getMatchBio = (match: Tables<'matches'>) => {
  // 这里需要根据实际需求实现，可能需要额外的查询
  return null
}

const formatMatchTime = (time: string) => {
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  
  if (days === 0) return '今天'
  if (days === 1) return '昨天'
  if (days < 7) return `${days}天前`
  if (days < 30) return `${Math.floor(days / 7)}周前`
  return `${Math.floor(days / 30)}个月前`
}

onMounted(async () => {
  await userStore.fetchUser()
  await matchStore.fetchMatches()
})
</script>