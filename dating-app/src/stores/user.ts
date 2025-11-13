import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@supabase/supabase-js'
import supabase from '@/lib/supabase'
import type { Tables } from '@/lib/types'

export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const profile = ref<Tables<'profiles'> | null>(null)
  const loading = ref(false)

  const isAuthenticated = computed(() => !!user.value)

  const fetchUser = async () => {
    loading.value = true
    try {
      const { data: { user: userData }, error: userError } = await supabase.auth.getUser()
      if (userError) throw userError
      
      user.value = userData
      
      if (userData) {
        const { data: profileData, error: profileError } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', userData.id)
          .single()
        
        if (profileError) throw profileError
        profile.value = profileData
      }
    } catch (error) {
      console.error('获取用户信息失败:', error)
    } finally {
      loading.value = false
    }
  }

  const updateProfile = async (updates: Partial<Tables<'profiles'>>) => {
    if (!user.value) throw new Error('用户未登录')
    
    const { data, error } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', user.value.id)
      .select()
      .single()
    
    if (error) throw error
    profile.value = data
    return data
  }

  const uploadAvatar = async (file: File) => {
    if (!user.value) throw new Error('用户未登录')
    
    const fileName = `${user.value.id}-${Date.now()}.${file.name.split('.').pop()}`
    
    const { error: uploadError } = await supabase.storage
      .from('avatars')
      .upload(fileName, file)
    
    if (uploadError) throw uploadError
    
    const { data: { publicUrl } } = supabase.storage
      .from('avatars')
      .getPublicUrl(fileName)
    
    await updateProfile({ avatar_url: publicUrl })
    return publicUrl
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    
    user.value = null
    profile.value = null
  }

  // 监听认证状态变化
  supabase.auth.onAuthStateChange((event, session) => {
    if (event === 'SIGNED_IN' && session?.user) {
      user.value = session.user
      fetchUser()
    } else if (event === 'SIGNED_OUT') {
      user.value = null
      profile.value = null
    }
  })

  return {
    user,
    profile,
    loading,
    isAuthenticated,
    fetchUser,
    updateProfile,
    uploadAvatar,
    signOut
  }
})