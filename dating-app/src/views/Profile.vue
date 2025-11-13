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
    <div class="max-w-4xl mx-auto px-4 py-8">
      <div class="bg-white rounded-lg shadow p-8">
        <h2 class="text-2xl font-bold mb-6">编辑个人资料</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <!-- 头像上传 -->
          <div class="text-center">
            <div class="mb-4">
              <img
                :src="avatarPreview || userStore.profile?.avatar_url || 'https://via.placeholder.com/200'"
                alt="头像"
                class="w-48 h-48 rounded-full mx-auto object-cover border-4 border-pink-200"
              />
            </div>
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              @change="handleFileChange"
              class="hidden"
            />
            <button
              @click="$refs.fileInput.click()"
              class="bg-pink-500 text-white py-2 px-4 rounded hover:bg-pink-600 transition-colors"
            >
              更换头像
            </button>
          </div>

          <!-- 资料表单 -->
          <form @submit.prevent="handleSubmit" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">昵称</label>
              <input
                v-model="form.nickname"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">性别</label>
              <select
                v-model="form.gender"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
              >
                <option value="male">男</option>
                <option value="female">女</option>
                <option value="other">其他</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">生日</label>
              <input
                v-model="form.birthday"
                type="date"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">城市</label>
              <input
                v-model="form.city"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
                placeholder="请输入城市"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">个人介绍</label>
              <textarea
                v-model="form.bio"
                rows="3"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
                placeholder="介绍一下自己吧..."
              ></textarea>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">兴趣标签</label>
              <input
                v-model="interestsInput"
                type="text"
                placeholder="用逗号分隔，如：音乐,电影,旅行"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
              />
            </div>

            <button
              type="submit"
              :disabled="loading"
              class="w-full bg-pink-500 text-white py-2 px-4 rounded hover:bg-pink-600 focus:outline-none focus:ring-2 focus:ring-pink-500 disabled:opacity-50"
            >
              {{ loading ? '保存中...' : '保存资料' }}
            </button>
          </form>
        </div>

        <div v-if="error" class="mt-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded">
          {{ error }}
        </div>

        <div v-if="success" class="mt-4 p-3 bg-green-100 border border-green-400 text-green-700 rounded">
          {{ success }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import type { Tables } from '@/lib/types'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const error = ref('')
const success = ref('')
const fileInput = ref<HTMLInputElement>()
const avatarPreview = ref('')

const form = ref<Partial<Tables<'profiles'>>({
  nickname: '',
  gender: 'male',
  birthday: '',
  city: '',
  bio: '',
  interests: []
})

const interestsInput = computed({
  get: () => (form.value.interests as string[])?.join(', ') || '',
  set: (value: string) => {
    form.value.interests = value.split(',').map(s => s.trim()).filter(Boolean)
  }
})

const handleFileChange = (event: Event) => {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      avatarPreview.value = e.target?.result as string
    }
    reader.readAsDataURL(file)
    
    // 上传头像
    uploadAvatar(file)
  }
}

const uploadAvatar = async (file: File) => {
  try {
    await userStore.uploadAvatar(file)
    success.value = '头像上传成功！'
  } catch (err: any) {
    error.value = err.message || '头像上传失败'
  }
}

const handleSubmit = async () => {
  loading.value = true
  error.value = ''
  success.value = ''
  
  try {
    await userStore.updateProfile(form.value)
    success.value = '资料保存成功！'
  } catch (err: any) {
    error.value = err.message || '保存失败'
  } finally {
    loading.value = false
  }
}

const handleLogout = async () => {
  await userStore.signOut()
  router.push('/login')
}

onMounted(async () => {
  await userStore.fetchUser()
  if (userStore.profile) {
    form.value = { ...userStore.profile }
  }
})
</script>