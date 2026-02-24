# OpenWork 功能列表

本文档详细列出了 OpenWork 项目的所有功能特性。

---

## 1. 项目概述

OpenWork 是一个开源的 Claude Cowork 替代品，采用 **Tauri 2.x + SolidJS** 技术栈构建的桌面应用程序，同时提供 Web 和 Cloud 版本。它提供 AI 辅助编程能力，支持移动优先设计理念。

### 1.1 基本信息

| 属性 | 值 |
|------|-----|
| 项目名称 | OpenWork |
| 版本 | 0.11.121 |
| 技术栈 | Tauri 2.x + SolidJS + TailwindCSS 4.x |
| 架构 | Monorepo (pnpm workspaces) |
| 许可证 | MIT |
| GitHub | different-ai/openwork |

### 1.2 Monorepo 结构

```
openwork/
├── packages/
│   ├── app/              # Tauri 桌面应用 (SolidJS 前端)
│   ├── server/           # OpenWork 服务器 (Bun/Node)
│   ├── web/              # Web 应用
│   ├── landing/          # 落地页
│   ├── docs/             # 文档站点
│   ├── orchestrator/     # 任务编排器
│   ├── opencode-router/  # OpenCode 路由
│   └── desktop/          # 桌面共享组件
├── ai-docs/              # 本文档目录
├── AGENTS.md            # 开发指南
└── pnpm-workspace.yaml
```

---

## 2. 核心包 (Core Packages)

### 2.1 packages/app - 桌面应用

桌面客户端应用，提供完整的 AI 辅助编程界面。

#### 2.1.1 页面 (Pages)

| 页面 | 描述 | 文件位置 |
|------|------|----------|
| onboarding | 引导流程，选择 Host/Client 模式 | `pages/onboarding.tsx` |
| dashboard | 主仪表板 | `pages/dashboard.tsx` |
| session | 交互式会话 | `pages/session.tsx` |
| settings | 应用设置 | `pages/settings.tsx` |
| skills | 技能管理 | `pages/skills.tsx` |
| scheduled | 定时任务 | `pages/scheduled.tsx` |
| extensions | 扩展管理 | `pages/extensions.tsx` |
| plugins | 插件管理 | `pages/plugins.tsx` |
| mcp | MCP 服务配置 | `pages/mcp.tsx` |
| identities | 身份管理 | `pages/identities.tsx` |
| config | 配置页面 | `pages/config.tsx` |
| soul | AI 灵魂/人格设置 | `pages/soul.tsx` |
| proto-workspaces | 工作区原型 | `pages/proto-workspaces.tsx` |
| proto-v1-ux | V1 UX 原型 | `pages/proto-v1-ux.tsx` |

#### 2.1.2 组件 (Components)

| 组件分类 | 组件 | 描述 |
|----------|------|------|
| 模态框 | model-picker-modal | 模型选择 |
| 模态框 | reset-modal | 重置确认 |
| 模态框 | create-workspace-modal | 创建工作区 |
| 模态框 | create-remote-workspace-modal | 创建远程工作区 |
| 模态框 | rename-workspace-modal | 重命名工作区 |
| 模态框 | mcp-auth-modal | MCP OAuth 认证 |
| 模态框 | provider-auth-modal | Provider OAuth 认证 |
| 模态框 | language-picker-modal | 语言选择 |
| 会话组件 | composer | 消息输入框 |
| 会话组件 | message-list | 消息列表 |
| 会话组件 | sidebar | 侧边栏 |
| 会话组件 | context-panel | 上下文面板 |
| 会话组件 | artifacts-panel | 产物面板 |
| 会话组件 | inbox-panel | 收件箱面板 |
| 会话组件 | minimap | 最小地图 |
| 会话组件 | thinking-block | AI 思考展示 |
| 会话组件 | part-view | 消息部分视图 |
| 会话组件 | artifact-markdown-editor | Markdown 编辑器 |
| 通用组件 | button | 按钮 |
| 通用组件 | card | 卡片 |
| 通用组件 | text-input | 文本输入 |
| 通用组件 | workspace-chip | 工作区标签 |
| 通用组件 | status-bar | 状态栏 |
| 通用组件 | openwork-logo | Logo |

#### 2.1.3 状态管理 (Context)

| Context | 描述 | 文件位置 |
|---------|------|----------|
| workspace | 工作区状态 | `context/workspace.ts` |
| session | 会话状态 | `context/session.ts` |
| server | 服务器状态 | `context/server.tsx` |
| global-sdk | 全局 SDK | `context/global-sdk.tsx` |
| extensions | 扩展状态 | `context/extensions.ts` |
| updater | 更新管理 | `context/updater.ts` |
| platform | 平台信息 | `context/platform.tsx` |
| sync | 同步状态 | `context/sync.tsx` |
| local | 本地状态 | `context/local.tsx` |

#### 2.1.4 核心库 (Lib)

| 库 | 描述 | 文件位置 |
|----|------|----------|
| opencode | OpenCode SDK 封装 | `lib/opencode.ts` |
| opencode-session | 会话操作 | `lib/opencode-session.ts` |
| tauri | Tauri 命令封装 | `lib/tauri.ts` |
| openwork-server | 服务器通信 | `lib/openwork-server.ts` |
| perf-log | 性能日志 | `lib/perf-log.ts` |
| publisher | 发布器 | `lib/publisher.ts` |
| safe-run | 安全运行 | `lib/safe-run.ts` |

### 2.2 packages/server - 服务器

OpenWork 后端服务器，提供 API 和任务执行能力。

| 模块 | 描述 | 文件位置 |
|------|------|----------|
| server.ts | 主服务器 | `server.ts` |
| cli.ts | CLI 入口 | `cli.ts` |
| commands.ts | 命令处理 | `commands.ts` |
| workspaces.ts | 工作区管理 | `workspaces.ts` |
| skills.ts | 技能管理 | `skills.ts` |
| plugins.ts | 插件管理 | `plugins.ts` |
| mcp.ts | MCP 集成 | `mcp.ts` |
| scheduler.ts | 任务调度 | `scheduler.ts` |
| events.ts | 事件系统 | `events.ts` |
| tokens.ts | Token 管理 | `tokens.ts` |
| config.ts | 配置管理 | `config.ts` |
| types.ts | 类型定义 | `types.ts` |

### 2.3 packages/web - Web 应用

基于 Web 的客户端，可通过浏览器访问。

### 2.4 packages/landing - 落地页

产品营销页面。

### 2.5 packages/docs - 文档

Mintlify 文档站点。

---

## 3. 核心功能 (Core Features)

### 3.1 工作区管理 (Workspace Management)

| 功能 | 描述 | 位置 |
|------|------|------|
| 创建工作区 | 创建新的本地工作区 | app/pages/onboarding.tsx |
| 创建远程工作区 | 连接到远程 OpenWork 服务器 | app/components/create-remote-workspace-modal.tsx |
| 工作区切换 | 快速切换工作区 | app/components/workspace-switch-overlay.tsx |
| 授权目录 | 管理授权访问的目录 | app/context/workspace.ts |
| 工作区分享 | 分享工作区给其他用户 | app/components/share-workspace-modal.tsx |
| 重命名工作区 | 修改工作区名称 | app/components/rename-workspace-modal.tsx |

### 3.2 会话管理 (Session Management)

| 功能 | 描述 | 位置 |
|------|------|------|
| 创建会话 | 创建新的 AI 对话 | app/pages/session.tsx |
| 会话列表 | 展示所有会话 | app/components/session/sidebar.tsx |
| 消息展示 | 实时消息更新 | app/components/session/message-list.tsx |
| 思考过程 | 展示 AI 推理 | app/components/thinking-block.tsx |
| 待办事项 | 任务待办列表 | app/app.tsx |
| 子任务/Agent | 支持子 Agent | app/app.tsx |
| Artifacts | AI 生成的文件/内容 | app/components/session/artifacts-panel.tsx |
| 上下文面板 | 当前上下文信息 | app/components/session/context-panel.tsx |
| 收件箱 | 收到的消息/任务 | app/components/session/inbox-panel.tsx |
| 最小地图 | 会话概览 | app/components/session/minimap.tsx |

### 3.3 模式支持 (Mode Support)

| 功能 | 描述 |
|------|------|
| Host 模式 | 本地运行 OpenWork 服务器 |
| Client 模式 | 连接到远程 OpenWork 服务器 |
| 远程连接 | 通过 URL + Token 连接 |

### 3.4 扩展功能 (Extensions)

| 功能 | 描述 | 位置 |
|------|------|------|
| 插件管理 | 安装/管理 OpenCode 插件 | app/pages/plugins.tsx |
| 技能管理 | 浏览/导入技能 | app/pages/skills.tsx |
| MCP 服务 | 连接外部服务 | app/pages/mcp.tsx |
| 身份管理 | Provider 身份 | app/pages/identities.tsx |

---

## 4. 新增功能 (New Features)

### 4.1 定时任务 (Scheduled Jobs)

| 功能 | 描述 |
|------|------|
| 创建定时任务 | 设置定时执行的 AI 任务 |
| 任务管理 | 启用/禁用/编辑定时任务 |
| 调度系统 | 基于 scheduler.ts 实现 |

### 4.2 Soul/人格设置

| 功能 | 描述 |
|------|------|
| AI 人格 | 自定义 AI 的个性和行为方式 |
| 个性化 | 设置 AI 的响应风格 |

### 4.3 分享功能

| 功能 | 描述 |
|------|------|
| 分享工作区 | 生成邀请链接 |
| 远程工作区 | 连接其他用户的共享工作区 |

### 4.4 多语言支持 (i18n)

| 功能 | 描述 |
|------|------|
| 中文 | 完整中文界面 |
| 英文 | 英文界面 |
| 扩展性强 | 基于 i18n 框架 |

---

## 5. 技术依赖

### 5.1 app 依赖

| 包 | 版本 | 用途 |
|----|------|------|
| solid-js | ^1.9.0 | UI 框架 |
| @solidjs/router | ^0.15.4 | 路由 |
| tailwindcss | ^4.1.18 | 样式 |
| @opencode-ai/sdk | ^1.1.31 | OpenCode SDK |
| @tauri-apps/api | ^2.0.0 | Tauri API |
| lucide-solid | ^0.562.0 | 图标 |
| marked | ^17.0.1 | Markdown 渲染 |
| @codemirror/* | ^6.x | 代码编辑器 |

### 5.2 server 依赖

| 包 | 用途 |
|----|------|
| Bun | 运行时 |
| 各类 TypeScript 依赖 | API、验证等 |

---

## 6. 安全特性

| 特性 | 描述 |
|------|------|
| Token 认证 | 基于 Token 的身份验证 |
| 工作区隔离 | 工作区之间相互隔离 |
| 权限控制 | 细粒度的权限管理 |
| OAuth 支持 | 第三方服务 OAuth 登录 |

---

## 7. 性能优化

| 特性 | 描述 |
|------|------|
| 性能日志 | perf-log.ts 记录性能数据 |
| CodeMirror 编辑器 | 高效的代码编辑体验 |
| SolidJS 响应式 | 高效的 UI 更新 |

---

*本文档最后更新于 2026-02-24*
