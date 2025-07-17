// 好友功能API模块
// 基于Supabase的好友管理API

class FriendshipAPI {
    constructor(supabaseClient) {
        this.supabase = supabaseClient;
    }

    // ===================== 好友关系管理 =====================

    /**
     * 获取用户的好友列表
     * @param {string} userId - 用户ID
     * @returns {Promise<Array>} 好友列表
     */
    async getFriendsList(userId) {
        try {
            const { data, error } = await this.supabase
                .from('user_friends')
                .select('*')
                .eq('user_id', userId);

            if (error) {
                console.error('获取好友列表失败:', error);
                throw error;
            }

            return data || [];
        } catch (error) {
            console.error('获取好友列表异常:', error);
            throw error;
        }
    }

    /**
     * 检查两个用户是否为好友
     * @param {string} userId1 - 用户1 ID
     * @param {string} userId2 - 用户2 ID
     * @returns {Promise<boolean>} 是否为好友
     */
    async checkFriendship(userId1, userId2) {
        try {
            const { data, error } = await this.supabase
                .from('friendships')
                .select('id')
                .or(`user_id.eq.${userId1},friend_id.eq.${userId1}`)
                .or(`user_id.eq.${userId2},friend_id.eq.${userId2}`)
                .limit(1);

            if (error) {
                console.error('检查好友关系失败:', error);
                throw error;
            }

            return data && data.length > 0;
        } catch (error) {
            console.error('检查好友关系异常:', error);
            throw error;
        }
    }

    /**
     * 删除好友关系
     * @param {string} userId - 当前用户ID
     * @param {string} friendId - 好友ID
     * @returns {Promise<boolean>} 是否成功
     */
    async removeFriend(userId, friendId) {
        try {
            const { error } = await this.supabase
                .from('friendships')
                .delete()
                .or(`user_id.eq.${userId},friend_id.eq.${userId}`)
                .or(`user_id.eq.${friendId},friend_id.eq.${friendId}`);

            if (error) {
                console.error('删除好友失败:', error);
                throw error;
            }

            return true;
        } catch (error) {
            console.error('删除好友异常:', error);
            throw error;
        }
    }

    // ===================== 好友请求管理 =====================

    /**
     * 发送好友请求
     * @param {string} senderId - 发送者ID
     * @param {string} receiverId - 接收者ID
     * @param {string} message - 请求消息（可选）
     * @returns {Promise<Object>} 请求结果
     */
    async sendFriendRequest(senderId, receiverId, message = '') {
        try {
            // 检查是否已经是好友
            const isFriend = await this.checkFriendship(senderId, receiverId);
            if (isFriend) {
                throw new Error('已经是好友关系');
            }

            // 检查是否已有待处理的请求
            const existingRequest = await this.getPendingRequest(senderId, receiverId);
            if (existingRequest) {
                throw new Error('已存在待处理的好友请求');
            }

            const { data, error } = await this.supabase
                .from('friend_requests')
                .insert({
                    sender_id: senderId,
                    receiver_id: receiverId,
                    message: message,
                    status: 'pending'
                })
                .select()
                .single();

            if (error) {
                console.error('发送好友请求失败:', error);
                throw error;
            }

            return data;
        } catch (error) {
            console.error('发送好友请求异常:', error);
            throw error;
        }
    }

    /**
     * 获取待处理的好友请求
     * @param {string} senderId - 发送者ID
     * @param {string} receiverId - 接收者ID
     * @returns {Promise<Object|null>} 请求对象或null
     */
    async getPendingRequest(senderId, receiverId) {
        try {
            const { data, error } = await this.supabase
                .from('friend_requests')
                .select('*')
                .eq('sender_id', senderId)
                .eq('receiver_id', receiverId)
                .eq('status', 'pending')
                .single();

            if (error && error.code !== 'PGRST116') { // PGRST116 表示没有找到记录
                console.error('获取待处理请求失败:', error);
                throw error;
            }

            return data || null;
        } catch (error) {
            console.error('获取待处理请求异常:', error);
            throw error;
        }
    }

    /**
     * 获取用户收到的待处理好友请求
     * @param {string} userId - 用户ID
     * @returns {Promise<Array>} 请求列表
     */
    async getReceivedRequests(userId) {
        try {
            const { data, error } = await this.supabase
                .from('pending_friend_requests')
                .select('*')
                .eq('receiver_id', userId);

            if (error) {
                console.error('获取收到的请求失败:', error);
                throw error;
            }

            return data || [];
        } catch (error) {
            console.error('获取收到的请求异常:', error);
            throw error;
        }
    }

    /**
     * 获取用户发送的待处理好友请求
     * @param {string} userId - 用户ID
     * @returns {Promise<Array>} 请求列表
     */
    async getSentRequests(userId) {
        try {
            const { data, error } = await this.supabase
                .from('friend_requests')
                .select(`
                    *,
                    receiver:users!friend_requests_receiver_id_fkey(
                        id,
                        nickname,
                        unique_id,
                        avatar_url
                    )
                `)
                .eq('sender_id', userId)
                .eq('status', 'pending');

            if (error) {
                console.error('获取发送的请求失败:', error);
                throw error;
            }

            return data || [];
        } catch (error) {
            console.error('获取发送的请求异常:', error);
            throw error;
        }
    }

    /**
     * 接受好友请求
     * @param {string} requestId - 请求ID
     * @param {string} receiverId - 接收者ID（当前用户）
     * @returns {Promise<Object>} 处理结果
     */
    async acceptFriendRequest(requestId, receiverId) {
        try {
            // 开始事务
            const { data: request, error: requestError } = await this.supabase
                .from('friend_requests')
                .select('*')
                .eq('id', requestId)
                .eq('receiver_id', receiverId)
                .eq('status', 'pending')
                .single();

            if (requestError || !request) {
                throw new Error('好友请求不存在或已被处理');
            }

            // 更新请求状态为已接受
            const { error: updateError } = await this.supabase
                .from('friend_requests')
                .update({ status: 'accepted' })
                .eq('id', requestId);

            if (updateError) {
                throw updateError;
            }

            // 创建好友关系
            const { error: friendshipError } = await this.supabase
                .from('friendships')
                .insert({
                    user_id: request.sender_id,
                    friend_id: request.receiver_id
                });

            if (friendshipError) {
                // 如果创建好友关系失败，回滚请求状态
                await this.supabase
                    .from('friend_requests')
                    .update({ status: 'pending' })
                    .eq('id', requestId);
                throw friendshipError;
            }

            return { success: true, request: request };
        } catch (error) {
            console.error('接受好友请求异常:', error);
            throw error;
        }
    }

    /**
     * 拒绝好友请求
     * @param {string} requestId - 请求ID
     * @param {string} receiverId - 接收者ID（当前用户）
     * @returns {Promise<boolean>} 是否成功
     */
    async rejectFriendRequest(requestId, receiverId) {
        try {
            const { error } = await this.supabase
                .from('friend_requests')
                .update({ status: 'rejected' })
                .eq('id', requestId)
                .eq('receiver_id', receiverId)
                .eq('status', 'pending');

            if (error) {
                console.error('拒绝好友请求失败:', error);
                throw error;
            }

            return true;
        } catch (error) {
            console.error('拒绝好友请求异常:', error);
            throw error;
        }
    }

    /**
     * 取消发送的好友请求
     * @param {string} requestId - 请求ID
     * @param {string} senderId - 发送者ID（当前用户）
     * @returns {Promise<boolean>} 是否成功
     */
    async cancelFriendRequest(requestId, senderId) {
        try {
            const { error } = await this.supabase
                .from('friend_requests')
                .delete()
                .eq('id', requestId)
                .eq('sender_id', senderId)
                .eq('status', 'pending');

            if (error) {
                console.error('取消好友请求失败:', error);
                throw error;
            }

            return true;
        } catch (error) {
            console.error('取消好友请求异常:', error);
            throw error;
        }
    }

    // ===================== 好友评分管理 =====================

    /**
     * 获取好友的评分数据
     * @param {string} userId - 当前用户ID
     * @param {Array<string>} friendIds - 好友ID列表
     * @returns {Promise<Array>} 好友评分列表
     */
    async getFriendsReviews(userId, friendIds) {
        try {
            if (!friendIds || friendIds.length === 0) {
                return [];
            }

            const { data, error } = await this.supabase
                .from('restaurant_reviews')
                .select(`
                    *,
                    user:users!restaurant_reviews_user_id_fkey(
                        id,
                        nickname,
                        unique_id,
                        avatar_url
                    )
                `)
                .in('user_id', friendIds)
                .eq('is_public', true)
                .order('created_at', { ascending: false });

            if (error) {
                console.error('获取好友评分失败:', error);
                throw error;
            }

            return data || [];
        } catch (error) {
            console.error('获取好友评分异常:', error);
            throw error;
        }
    }

    /**
     * 获取所有好友的评分数据（包括当前用户）
     * @param {string} userId - 当前用户ID
     * @returns {Promise<Array>} 所有评分列表
     */
    async getAllFriendsReviews(userId) {
        try {
            // 获取好友列表
            const friends = await this.getFriendsList(userId);
            const friendIds = friends.map(friend => friend.friend_id);
            
            // 添加当前用户ID
            const allUserIds = [userId, ...friendIds];

            const { data, error } = await this.supabase
                .from('restaurant_reviews')
                .select(`
                    *,
                    user:users!restaurant_reviews_user_id_fkey(
                        id,
                        nickname,
                        unique_id,
                        avatar_url
                    )
                `)
                .in('user_id', allUserIds)
                .eq('is_public', true)
                .order('created_at', { ascending: false });

            if (error) {
                console.error('获取所有好友评分失败:', error);
                throw error;
            }

            return data || [];
        } catch (error) {
            console.error('获取所有好友评分异常:', error);
            throw error;
        }
    }

    // ===================== 用户搜索 =====================

    /**
     * 搜索用户（用于添加好友）
     * @param {string} searchTerm - 搜索关键词（昵称或unique_id）
     * @param {string} currentUserId - 当前用户ID（排除自己）
     * @returns {Promise<Array>} 用户列表
     */
    async searchUsers(searchTerm, currentUserId) {
        try {
            const { data, error } = await this.supabase
                .from('users')
                .select('id, nickname, unique_id, avatar_url, created_at')
                .or(`nickname.ilike.%${searchTerm}%,unique_id.ilike.%${searchTerm}%`)
                .neq('id', currentUserId)
                .limit(10);

            if (error) {
                console.error('搜索用户失败:', error);
                throw error;
            }

            return data || [];
        } catch (error) {
            console.error('搜索用户异常:', error);
            throw error;
        }
    }

    /**
     * 根据unique_id获取用户信息
     * @param {string} uniqueId - 用户唯一标识
     * @returns {Promise<Object|null>} 用户信息
     */
    async getUserByUniqueId(uniqueId) {
        try {
            const { data, error } = await this.supabase
                .from('users')
                .select('id, nickname, unique_id, avatar_url, created_at')
                .eq('unique_id', uniqueId)
                .single();

            if (error && error.code !== 'PGRST116') {
                console.error('获取用户信息失败:', error);
                throw error;
            }

            return data || null;
        } catch (error) {
            console.error('获取用户信息异常:', error);
            throw error;
        }
    }
}

// 导出API类
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FriendshipAPI;
} else {
    window.FriendshipAPI = FriendshipAPI;
} 