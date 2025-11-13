<template>
  <div class="min-h-screen bg-gradient-to-br from-pink-100 to-purple-100 flex items-center justify-center p-4">
    <div class="bg-white rounded-lg shadow-xl p-8 w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-800 mb-2">💞 注册账号</h1>
        <p class="text-gray-600">创建你的交友档案</p>
      </div>

      <form @submit.prevent="handleRegister" class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">邮箱</label>
          <input
            v-model="email"
            type="email"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
            placeholder="请输入邮箱"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">密码</label>
          <input
            v-model="password"
            type="password"
            required
            minlength="6"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
            placeholder="至少6位字符"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">昵称</label>
          <input
            v-model="nickname"
            type="text"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
            placeholder="请输入昵称"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">性别</label>
          <select
            v-model="gender"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
          >
            <option value="">请选择性别</option>
            <option value="male">男</option>
            <option value="female">女</option>
            <option value="other">其他</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">生日</label>
          <input
            v-model="birthday"
            type="date"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">城市</label>
          <input
            v-model="city"
            type="text"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
            placeholder="请输入城市（可选）"
          />
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="w-full bg-pink-500 text-white py-2 px-4 rounded-md hover:bg-pink-600 focus:outline-none focus:ring-2 focus:ring-pink-500 disabled:opacity-50"
        >
          {{ loading ? '注册中...' : '注册' }}
        </button>
      </form>

      <div class="mt-6 text-center">
        <p class="text-gray-600">
          已有账号？
          <router-link to="/login" class="text-pink-500 hover:text-pink-600">
            立即登录
          </router-link>
        </p>
      </div>

      <div v-if="error" class="mt-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded">
        {{ error }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import supabase from '@/lib/supabase'

const router = useRouter()
const email = ref('')
const password = ref('')
const nickname = ref('')
const gender = ref('')
const birthday = ref('')
const city = ref('')
const loading = ref(false)
const error = ref('')

const handleRegister = async () => {
  loading.value = true
  error.value = ''
  
  try {
    // 1. 注册用户
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: email.value,
      password: password.value
    })
    
    if (authError) throw authError
    
    // 2. 更新用户资料
    if (authData.user) {
      const { error: profileError } = await supabase
        .from('profiles')
        .update({
          nickname: nickname.value,
          gender: gender.value,
          birthday: birthday.value,
          city: city.value
        })
        .eq('id', authData.user.id)
      
      if (profileError) throw profileError
    }
    
    router.push('/login')
  } catch (err: any) {
    error.value = err.message || '注册失败'
  } finally {
    loading.value = false
  }
}
</script>