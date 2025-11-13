import { defineStore } from 'pinia'
import { ref } from 'vue'
import supabase from '@/lib/supabase'
import type { Tables } from '@/lib/types'
import { useUserStore } from './user'

export const useMatchStore = defineStore('match', () => {
  const matches = ref<Tables<'matches'>[]>([])
  const potentialMatches = ref<Tables<'profiles'>[]>([])
  const loading = ref(false)

  const fetchMatches = async () => {
    const userStore = useUserStore()
    if (!userStore.user) return

    loading.value = true
    try {
      const { data, error } = await supabase
        .from('matches')
        .select(`
          *,
          user_a_profile:profiles!user_a(id, nickname, avatar_url, city, bio),
          user_b_profile:profiles!user_b(id, nickname, avatar_url, city, bio)
        `)
        .or(`user_a.eq.${userStore.user.id},user_b.eq.${userStore.user.id}`)
        .order('created_at', { ascending: false })

      if (error) throw error
      matches.value = data || []
    } catch (error) {
      console.error('获取匹配列表失败:', error)
    } finally {
      loading.value = false
    }
  }

  const fetchPotentialMatches = async () => {
    const userStore = useUserStore()
    if (!userStore.user || !userStore.profile) return

    loading.value = true
    try {
      // 获取当前用户已经点赞的用户ID
      const { data: likedUsers } = await supabase
        .from('likes')
        .select('target_id')
        .eq('user_id', userStore.user.id)

      const likedUserIds = likedUsers?.map(like => like.target_id) || []
      likedUserIds.push(userStore.user.id) // 排除自己

      // 获取潜在匹配用户
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .not('id', 'in', `(${likedUserIds.join(',')})`)
        .limit(10)

      if (error) throw error
      potentialMatches.value = data || []
    } catch (error) {
      console.error('获取潜在匹配失败:', error)
    } finally {
      loading.value = false
    }
  }

  const likeUser = async (targetId: string) => {
    const userStore = useUserStore()
    if (!userStore.user) return

    try {
      // 创建点赞记录
      const { error: likeError } = await supabase
        .from('likes')
        .insert({
          user_id: userStore.user.id,
          target_id: targetId
        })

      if (likeError) throw likeError

      // 检查是否互相点赞（匹配）
      const { data: mutualLike } = await supabase
        .from('likes')
        .select('user_id')
        .eq('user_id', targetId)
        .eq('target_id', userStore.user.id)
        .single()

      if (mutualLike) {
        // 创建匹配记录
        const { error: matchError } = await supabase
          .from('matches')
          .insert({
            user_a: userStore.user.id,
            user_b: targetId
          })

        if (matchError) throw matchError

        return true // 表示匹配成功
      }

      return false // 表示只是单向点赞
    } catch (error) {
      console.error('点赞失败:', error)
      throw error
    }
  }

  const sendMessage = async (receiverId: string, content: string) => {
    const userStore = useUserStore()
    if (!userStore.user) return

    try {
      const { error } = await supabase
        .from('messages')
        .insert({
          sender_id: userStore.user.id,
          receiver_id: receiverId,
          content,
          type: 'text'
        })

      if (error) throw error
    } catch (error) {
      console.error('发送消息失败:', error)
      throw error
    }
  }

  return {
    matches,
    potentialMatches,
    loading,
    fetchMatches,
    fetchPotentialMatches,
    likeUser,
    sendMessage
  }
})