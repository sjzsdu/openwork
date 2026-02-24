# OpenWork 架构文档

本文档详细描述了 OpenWork 项目的系统架构、设计模式和模块关系。

---

## 1. 整体架构概述

OpenWork 采用 **Monorepo + 客户端-服务器** 架构，结合了现代前端响应式开发范式、TypeScript 服务器和原生 Rust 后端的高效性能。

### 1.1 Monorepo 结构

```
openwork/                           # 根目录
├── packages/
│   ├── app/                       # Tauri 桌面应用 (SolidJS)
│   │   ├── src/
│   │   │   ├── app/              # 主应用代码
│   │   │   │   ├── app.tsx       # 主组件
│   │   │   │   ├── pages/        # 页面组件
│   │   │   │   ├── components/   # UI 组件
│   │   │   │   ├── context/      # 状态管理 (Context)
│   │   │   │   ├── lib/          # 工具库
│   │   │   │   ├── state/        # 状态管理
│   │   │   │   ├── utils/        # 工具函数
│   │   │   │   ├── types.ts      # 类型定义
│   │   │   │   ├── constants.ts  # 常量
│   │   │   │   ├── theme.ts      # 主题
│   │   │   │   └── mcp.ts        # MCP 相关
│   │   │   ├── i18n/             # 国际化
│   │   │   ├── styles/           # 样式
│   │   │   └── index.tsx         # 入口
│   │   └── package.json
│   │
│   ├── server/                   # OpenWork 服务器 (Bun)
│   │   ├── src/
│   │   │   ├── server.ts         # 主服务器
│   │   │   ├── cli.ts            # CLI 入口
│   │   │   ├── commands.ts       # 命令处理
│   │   │   ├── workspaces.ts     # 工作区管理
│   │   │   ├── skills.ts         # 技能管理
│   │   │   ├── plugins.ts        # 插件管理
│   │   │   ├── mcp.ts            # MCP 集成
│   │   │   ├── scheduler.ts      # 任务调度
│   │   │   ├── events.ts         # 事件系统
│   │   │   ├── tokens.ts         # Token 管理
│   │   │   └── ...
│   │   └── package.json
│   │
│   ├── web/                      # Web 应用
│   ├── landing/                  # 落地页
│   ├── docs/                     # 文档
│   ├── orchestrator/             # 编排器
│   ├── opencode-router/         # 路由
│   └── desktop/                  # 桌面组件
│
└── pnpm-workspace.yaml
```

### 1.2 架构层次

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│                    (SolidJS + TailwindCSS 4)               │
│   Pages: onboarding, dashboard, session, settings...       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      State Management                        │
│                 (SolidJS Context + Signals)                │
│   workspace, session, server, extensions, updater...      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Integration Layer                         │
│              (Tauri Commands + OpenCode SDK)               │
│   lib/opencode.ts, lib/tauri.ts, lib/openwork-server.ts   │
└─────────────────────────────────────────────────────────────┘
                              │
            ┌─────────────────┴─────────────────┐
            ▼                                   ▼
┌───────────────────────┐           ┌───────────────────────┐
│    OpenWork Server    │           │   OpenCode Engine    │
│      (Bun/Node)       │           │   (External CLI)     │
│   packages/server/    │           │   opencode CLI       │
└───────────────────────┘           └───────────────────────┘
```

---

## 2. app 包架构 (Desktop App)

### 2.1 目录结构

```
packages/app/src/
├── app/
│   ├── app.tsx                  # 主应用组件 (5000+ 行)
│   ├── entry.tsx               # 入口点
│   ├── types.ts                # 类型定义
│   ├── constants.ts            # 常量配置
│   ├── theme.ts               # 主题配置
│   ├── mcp.ts                 # MCP 工具函数
│   │
│   ├── pages/                  # 页面组件 (14个)
│   │   ├── onboarding.tsx
│   │   ├── dashboard.tsx
│   │   ├── session.tsx
│   │   ├── settings.tsx
│   │   ├── skills.tsx
│   │   ├── scheduled.tsx       # 新增：定时任务
│   │   ├── extensions.tsx
│   │   ├── plugins.tsx
│   │   ├── mcp.tsx
│   │   ├── identities.tsx      # 新增：身份管理
│   │   ├── config.tsx
│   │   ├── soul.tsx            # 新增：人格设置
│   │   ├── proto-workspaces.tsx
│   │   └── proto-v1-ux.tsx
│   │
│   ├── components/             # UI 组件 (30+)
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── text-input.tsx
│   │   ├── modal/              # 各种模态框
│   │   ├── session/           # 会话相关组件
│   │   │   ├── composer.tsx
│   │   │   ├── message-list.tsx
│   │   │   ├── sidebar.tsx
│   │   │   ├── context-panel.tsx
│   │   │   ├── artifacts-panel.tsx
│   │   │   ├── inbox-panel.tsx
│   │   │   ├── minimap.tsx
│   │   │   └── ...
│   │   └── ...
│   │
│   ├── context/                # SolidJS Context (9个)
│   │   ├── workspace.ts
│   │   ├── session.ts
│   │   ├── server.tsx
│   │   ├── global-sdk.tsx
│   │   ├── extensions.ts
│   │   ├── updater.ts
│   │   ├── platform.tsx
│   │   ├── sync.tsx
│   │   └── local.tsx
│   │
│   ├── lib/                    # 工具库
│   │   ├── opencode.ts         # OpenCode SDK 封装
│   │   ├── opencode-session.ts # 会话操作
│   │   ├── tauri.ts            # Tauri 命令
│   │   ├── openwork-server.ts # 服务器通信
│   │   ├── perf-log.ts        # 性能日志
│   │   ├── publisher.ts        # 发布器
│   │   └── safe-run.ts         # 安全运行
│   │
│   ├── state/                  # 状态管理
│   │   ├── sessions.ts
│   │   ├── system.ts
│   │   └── extensions.ts
│   │
│   └── utils/                  # 工具函数
│       ├── index.ts
│       ├── plugins.ts
│       ├── persist.ts
│       └── providers.ts
│
├── i18n/                       # 国际化
│   ├── index.ts
│   └── locales/
│       ├── index.ts
│       ├── en.ts
│       └── zh.ts
│
├── styles/                     # 样式
│   └── tailwind-colors.ts
│
└── index.tsx                   # 入口文件
```

### 2.2 状态管理架构

使用 SolidJS 的 **Context** 模式进行状态管理：

| Context | 职责 | 关键状态 |
|---------|------|----------|
| `workspace` | 工作区管理 | workspaces, activeWorkspace, authorizedDirs |
| `session` | 会话管理 | sessions, messages, todos, permissions |
| `server` | 服务器连接 | serverUrl, connected, authToken |
| `global-sdk` | OpenCode SDK | client, engine |
| `extensions` | 扩展管理 | skills, plugins |
| `updater` | 更新管理 | updateStatus, downloadProgress |
| `platform` | 平台信息 | isTauri, isMobile, platform |
| `sync` | 同步状态 |Synced |
| `local` | 本 syncStatus, last地状态 | preferences, cache |

### 2.3 路由架构

使用 `@solidjs/router`：

```
/                   → dashboard
/onboarding         → onboarding
/session/:id       → session
/settings           → settings
/settings/:tab      → settings (with tab)
/skills             → skills
/scheduled          → scheduled
/extensions         → extensions
/plugins            → plugins
/mcp                → mcp
/identities         → identities
/config             → config
/soul               → soul
```

---

## 3. server 包架构

### 3.1 目录结构

```
packages/server/src/
├── server.ts              # 主服务器 (Bun.serve)
├── cli.ts                 # CLI 入口
├── commands.ts           # 命令处理
├── workspaces.ts         # 工作区 CRUD
├── skills.ts             # 技能管理
├── plugins.ts            # 插件管理
├── mcp.ts               # MCP 服务器
├── scheduler.ts         # 定时任务调度
├── events.ts            # SSE 事件
├── tokens.ts            # Token 生成/验证
├── config.ts            # 配置管理
├── types.ts            # 类型定义
├── validators.ts       # 输入验证
├── paths.ts            # 路径工具
├── utils.ts            # 工具函数
├── errors.ts           # 错误处理
├── audit.ts            # 审计日志
├── approvals.ts        # 审批流程
├── skill-hub.ts        # 技能中心
├── frontmatter.ts      # 解析
├── reload-watcher.ts   # 热重载
└── ...
```

### 3.2 API 架构

| 端点 | 描述 |
|------|------|
| `GET /health` | 健康检查 |
| `GET /workspaces` | 列出工作区 |
| `POST /workspaces` | 创建工作区 |
| `GET /workspaces/:id` | 获取工作区 |
| `DELETE /workspaces/:id` | 删除工作区 |
| `GET /sessions` | 列出会话 |
| `POST /sessions` | 创建会话 |
| `GET /skills` | 列出技能 |
| `POST /skills/import` | 导入技能 |
| `GET /scheduler/jobs` | 定时任务 |
| `POST /scheduler/jobs` | 创建任务 |

---

## 4. 模块交互

### 4.1 应用启动流程

```
1. 用户启动应用 (Tauri)
   │
   ▼
2. app/entry.tsx
   └── App 组件挂载
   │
   ▼
3. app/app.tsx onMount()
   ├── 读取 LocalStorage 偏好
   ├── 初始化 Context
   ├── 检查更新
   └── 加载工作区
   │
   ▼
4. 路由导航
   ├── 未配置 → /onboarding
   ├── 已配置 → /dashboard
   └── 深链接 → 对应页面
```

### 4.2 连接服务器流程

```
1. 用户选择模式 (Host/Client)
   │
   ▼
2. Host 模式
   ├── 启动本地 OpenWork Server
   │   └── packages/server/src/cli.ts
   └── 连接到 localhost
   │
   ▼
3. Client 模式
   ├── 输入服务器 URL
   ├── 输入/获取 Token
   └── 连接到远程服务器
   │
   ▼
4. 建立连接
   ├── 创建 OpenCode Client
   ├── 初始化 SSE 监听
   └── 加载会话/技能/插件
```

### 4.3 会话交互流程

```
1. 用户输入 prompt
   │
   ▼
2. composer.tsx 提交
   │
   ▼
3. app.tsx sendPrompt()
   ├── 调用 client.session.promptAsync()
   └── 设置 busy 状态
   │
   ▼
4. SSE 事件监听
   ├── session.updated
   ├── message.updated
   ├── todo.updated
   ├── permission.asked
   └── session.status
   │
   ▼
5. Context 更新触发 UI 重渲染
```

---

## 5. 设计模式

### 5.1 Context 依赖注入

```typescript
// context/workspace.ts
export function createWorkspaceContext() {
  const [workspaces, setWorkspaces] = createSignal<Workspace[]>([]);
  
  return {
    workspaces,
    setWorkspaces,
    createWorkspace: async () => { /* ... */ },
    // ...
  };
}

// 使用
const { workspaces, createWorkspace } = useWorkspace();
```

### 5.2 Provider 模式

```typescript
// app.tsx
<WorkspaceProvider>
  <SessionProvider>
    <ExtensionsProvider>
      <AppContent />
    </ExtensionsProvider>
  </SessionProvider>
</WorkspaceProvider>
```

### 5.3 路由守卫

```typescript
// 路由守卫示例
function ProtectedRoute(props) {
  const { isConnected } = useServer();
  
  return isConnected() 
    ? props.children 
    : <Navigate href="/onboarding" />;
}
```

---

## 6. 安全架构

### 6.1 认证流程

```
┌─────────────────────────────────────────────────────────────┐
│                    认证层级                                  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  全局认证 (Global)                                   │   │
│  │  - 服务器 Token                                      │   │
│  │  - OAuth 登录                                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  工作区认证 (Workspace)                              │   │
│  │  - 工作区特定 Token                                  │   │
│  │  - 邀请链接                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  会话认证 (Session)                                 │   │
│  │  - 文件访问请求                                       │   │
│  │  - 命令执行请求                                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 Token 类型

| Token 类型 | 用途 | 有效期 |
|------------|------|--------|
| 服务器 Token | 连接到 OpenWork 服务器 | 长期 |
| 工作区 Token | 访问特定工作区 | 可配置 |
| 临时 Token | OAuth 回调 | 短期 |

---

## 7. 性能优化

### 7.1 前端优化

- **SolidJS 响应式**: 精细化更新
- **CodeMirror**: 高效代码编辑
- **perf-log.ts**: 性能监控
- **路由懒加载**: 按需加载页面

### 7.2 后端优化

- **Bun 运行时**: 高性能
- **SSE**: 实时推送
- **热重载**: reload-watcher.ts

---

*本文档最后更新于 2026-02-24*
