# OpenWork 项目文档

欢迎来到 OpenWork 项目文档索引页。

---

## 项目简介

**OpenWork** 是一个开源的 Claude Cowork 替代品，采用 **Tauri 2.x + SolidJS** 技术栈构建。它提供 AI 辅助编程能力，支持移动优先的设计理念。项目现在采用 **Monorepo** 架构，包含多个包。

| 属性 | 值 |
|------|-----|
| 项目名称 | OpenWork |
| 版本 | 0.11.121 |
| 技术栈 | Tauri 2.x + SolidJS + TailwindCSS 4.x |
| 架构 | Monorepo (pnpm workspaces) |
| 许可证 | MIT |
| GitHub | [different-ai/openwork](https://github.com/different-ai/openwork) |

---

## Monorepo 结构

```
openwork/
├── packages/
│   ├── app/              # Tauri 桌面应用 (SolidJS 前端)
│   ├── server/           # OpenWork 服务器 (Bun)
│   ├── web/              # Web 应用
│   ├── landing/          # 落地页
│   ├── docs/             # 文档站点
│   ├── orchestrator/     # 任务编排器
│   ├── opencode-router/  # OpenCode 路由
│   └── desktop/          # 桌面共享组件
└── pnpm-workspace.yaml
```

---

## 文档目录

### 1. [功能列表](./FEATURES.md)

详细列出项目的所有功能特性，包括：

- **核心包**: app, server, web 等
- **页面**: onboarding, dashboard, session, settings 等
- **组件**: 模态框、会话组件、通用组件
- **Context**: 9 个状态管理 Context
- **新增功能**: 定时任务、Soul 人格、分享功能、i18n

**适合**: 了解项目功能全貌

---

### 2. [架构文档](./ARCHITECTURE.md)

深入分析项目的系统架构，包括：

- **整体架构**: Monorepo 结构
- **app 包架构**: 目录结构、状态管理、路由
- **server 包架构**: API 端点、模块划分
- **模块交互**: 启动流程、连接流程、会话交互
- **设计模式**: Context 依赖注入、Provider 模式、路由守卫
- **安全架构**: 认证层级、Token 类型

**适合**: 理解系统设计和技术实现

---

### 3. [架构图](./DIAGRAMS.md)

包含所有架构的 Mermaid 图表：

- **系统架构图**: Monorepo 结构、整体架构
- **路由图**: 页面路由结构
- **状态管理图**: Context 关系、持久化
- **流程图**: 消息发送、服务器连接
- **组件关系图**: app.tsx 组件树、Session 组件
- **API 图**: 端点划分
- **权限图**: 认证层级
- **部署图**: 部署模式

**适合**: 直观理解系统结构和工作流程

---

## 快速开始

### 安装依赖

```bash
cd packages/app
pnpm install
```

### 开发模式

```bash
# 桌面应用
cd packages/app
pnpm dev

# 服务器
cd packages/server
pnpm dev
```

### 构建

```bash
# 桌面应用
cd packages/app
pnpm build

# 服务器
cd packages/server
pnpm build
```

### 测试

```bash
# app 测试
cd packages/app
pnpm test:health        # 健康检查
pnpm test:sessions     # 会话测试
pnpm test:e2e          # 端到端测试
```

---

## 核心概念

### 工作区 (Workspace)

工作区是 OpenWork 的核心概念，用于管理用户的项目目录。支持：
- 本地工作区
- 远程工作区（连接其他用户的服务器）
- 工作区分享（邀请链接）

### 会话 (Session)

会话代表与 AI 助手的交互任务。通过 SSE 事件实现实时消息更新。支持：
- 子 Agent/子任务
- Artifacts（AI 生成的文件/内容）
- 待办事项

### 模式 (Mode)

- **Host 模式**: 本地运行 OpenWork 服务器
- **Client 模式**: 连接到远程 OpenWork 服务器

### Context 状态管理

使用 SolidJS 的 Context 模式进行状态管理：
- `workspace` - 工作区状态
- `session` - 会话状态
- `server` - 服务器状态
- `global-sdk` - OpenCode SDK
- `extensions` - 扩展状态
- `updater` - 更新管理
- `platform` - 平台信息
- `sync` - 同步状态
- `local` - 本地状态

---

## 新增功能 (近期更新)

### 定时任务 (Scheduled Jobs)
- 创建定时执行的 AI 任务
- 基于 scheduler.ts 实现

### Soul/人格设置
- 自定义 AI 的个性和行为方式

### 分享功能
- 生成邀请链接分享工作区
- 连接其他用户的共享工作区

### 多语言支持 (i18n)
- 中文界面
- 英文界面

---

## 相关资源

- [GitHub 仓库](https://github.com/different-ai/openwork)
- [AGENTS.md](../AGENTS.md) - 开发指南
- [PRODUCT.md](../PRODUCT.md) - 产品需求
- [ARCHITECTURE.md](../ARCHITECTURE.md) - 架构说明
- [INFRASTRUCTURE.md](../INFRASTRUCTURE.md) - 基础设施
- [OpenCode SDK](https://github.com/opencode-ai/sdk)

---

## 文档版本

| 版本 | 日期 | 说明 |
|------|------|------|
| 2.0.0 | 2026-02-24 | Monorepo 架构重构 |
| 1.0.0 | 2024-xx-xx | 初始版本 |

---

*本文档最后更新于 2026-02-24*
