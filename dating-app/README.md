# 💞 交友网站 - 部署指南

基于 Vue3 + TypeScript + Supabase + Vercel 的现代化交友平台

## 🚀 快速开始

### 1. 环境要求
- Node.js 18+
- npm 或 pnpm
- Git

### 2. 本地开发
```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建项目
npm run build
```

## 📦 部署步骤

### 1. 配置 Supabase

1. 访问 [Supabase](https://supabase.com) 创建免费账户
2. 创建新项目，记录项目 URL 和密钥
3. 在 SQL Editor 中执行 `supabase/migrations/001_init_schema.sql`
4. 启用邮箱认证：Authentication → Providers → Email

### 2. 配置环境变量

复制 `.env.example` 为 `.env`：
```bash
cp .env.example .env
```

填写你的 Supabase 配置：
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_KEY=your_supabase_anon_key
SUPABASE_SERVICE_KEY=your_supabase_service_role_key
```

### 3. 部署到 Vercel

1. 访问 [Vercel](https://vercel.com) 并连接 GitHub
2. 导入此项目仓库
3. 在环境变量中添加：
   - `SUPABASE_URL`
   - `SUPABASE_KEY`
   - `SUPABASE_SERVICE_KEY`
4. 点击 Deploy 完成部署

## 🛠️ 技术栈

- **前端**: Vue 3 + TypeScript + Vite
- **UI**: Tailwind CSS
- **状态管理**: Pinia
- **后端**: Supabase (PostgreSQL + Auth + Storage)
- **部署**: Vercel
- **实时通信**: Supabase Realtime

## 📋 功能特性

✅ 用户注册登录（邮箱认证）
✅ 个人资料管理
✅ 头像上传（Supabase Storage）
✅ 用户匹配系统
✅ 实时聊天功能
✅ 响应式设计
✅ 行级安全（RLS）

## 🔒 安全特性

- JWT Token 认证
- 行级安全策略（RLS）
- 图片访问权限控制
- HTTPS 强制加密

## 📊 数据库结构

### 核心表
- `profiles`: 用户资料表
- `likes`: 用户点赞记录
- `matches`: 用户匹配关系
- `messages`: 聊天消息
- `posts`: 用户动态（可选）

## 🚀 后续开发

### 计划功能
- [ ] 实时聊天界面
- [ ] 用户搜索过滤
- [ ] 动态发布功能
- [ ] 会员系统
- [ ] AI 智能推荐
- [ ] 视频通话

### 性能优化
- [ ] 图片懒加载
- [ ] 虚拟滚动
- [ ] 缓存策略
- [ ] CDN 加速

## 📝 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 支持

如有问题，请在 GitHub 提交 Issue。