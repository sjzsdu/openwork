# OpenWork 架构图表

本文档包含 OpenWork 项目所有架构的 Mermaid 图表。

---

## 1. 系统架构图

### 1.1 Monorepo 结构

```mermaid
flowchart TB
    subgraph Root["openwork/ (根目录)"]
        Config["pnpm-workspace.yaml<br/>AGENTS.md<br/>package.json"]
    end
    
    subgraph Packages["packages/"]
        direction LR
        App["app/<br/>Tauri 桌面应用"]
        Server["server/<br/>Bun 服务器"]
        Web["web/<br/>Web 应用"]
        Landing["landing/<br/>落地页"]
        Docs["docs/<br/>文档站点"]
        Orchestrator["orchestrator/<br/>编排器"]
        Router["opencode-router/<br/>路由"]
        Desktop["desktop/<br/>桌面组件"]
    end
    
    Config --> Packages
```

### 1.2 整体架构

```mermaid
flowchart TB
    subgraph Frontend["桌面应用 (packages/app)"]
        Pages["Pages<br/>onboarding/dashboard/session..."]
        Components["Components<br/>Button/Card/Modal/Session..."]
        App["app.tsx<br/>主应用 (5000+行)"]
    end
    
    subgraph Context["Context 状态管理 (9个)"]
        WorkspaceCtx["workspace"]
        SessionCtx["session"]
        ServerCtx["server"]
        GlobalSDK["global-sdk"]
        ExtensionsCtx["extensions"]
        UpdaterCtx["updater"]
        PlatformCtx["platform"]
    end
    
    subgraph Lib["lib/ 工具库"]
        OpenCodeLib["opencode.ts<br/>SDK 封装"]
        TauriLib["tauri.ts<br/>命令封装"]
        ServerLib["openwork-server.ts<br/>服务器通信"]
        PerfLib["perf-log.ts<br/>性能日志"]
    end
    
    subgraph Backend["packages/server"]
        API["server.ts<br/>API 端点"]
        WorkspaceMgr["workspaces.ts<br/>工作区"]
        SkillsMgr["skills.ts<br/>技能"]
        Scheduler["scheduler.ts<br/>定时任务"]
        Events["events.ts<br/>SSE"]
    end
    
    subgraph External["外部服务"]
        OpenCodeEngine["OpenCode Engine"]
        MCP["MCP Servers"]
    end
    
    Pages --> App
    Components --> App
    App --> Context
    App --> Lib
    
    Lib --> Backend
    Backend --> OpenCodeEngine
    OpenCodeEngine <--> MCP
```

---

## 2. 页面路由图

### 2.1 路由结构

```mermaid
flowchart TB
    subgraph Routes["路由"]
        Onboarding["/onboarding"]
        Dashboard["/dashboard"]
        Session["/session/:id"]
        Settings["/settings"]
        SettingsTab["/settings/:tab"]
        Skills["/skills"]
        Scheduled["/scheduled"]
        Extensions["/extensions"]
        Plugins["/plugins"]
        MCP["/mcp"]
        Identities["/identities"]
        Config["/config"]
        Soul["/soul"]
    end
    
    Dashboard --> Onboarding
    Session --> Dashboard
    Settings --> Dashboard
    Settings --> SettingsTab
    Skills --> Dashboard
    Scheduled --> Dashboard
    Extensions --> Dashboard
    Plugins --> Dashboard
    MCP --> Dashboard
    Identities --> Dashboard
    Config --> Dashboard
    Soul --> Dashboard
```

---

## 3. 状态管理图

### 3.1 Context 关系

```mermaid
flowchart LR
    subgraph App["app.tsx (根)"]
        Providers["<WorkspaceProvider><br/><SessionProvider><br/><ServerProvider><br/>..."]
    end
    
    subgraph Contexts["9 个 Context"]
        WC["workspace.ts<br/>工作区状态"]
        SC["session.ts<br/>会话状态"]
        SrvC["server.tsx<br/>服务器状态"]
        GSDK["global-sdk.tsx<br/>SDK 状态"]
        EC["extensions.ts<br/>扩展状态"]
        UC["updater.ts<br/>更新状态"]
        PC["platform.tsx<br/>平台信息"]
        SyncC["sync.tsx<br/>同步状态"]
        LC["local.tsx<br/>本地状态"]
    end
    
    Providers --> WC
    Providers --> SC
    Providers --> SrvC
    Providers --> GSDK
    Providers --> EC
    Providers --> UC
    Providers --> PC
    Providers --> SyncC
    Providers --> LC
```

### 3.2 状态持久化

```mermaid
flowchart LR
    subgraph LocalStorage["LocalStorage"]
        LS_Model["openwork.modelPref"]
        LS_Theme["openwork.theme"]
        LS_Lang["openwork.language"]
        LS_Server["openwork.serverUrl"]
    end
    
    subgraph State["应用状态"]
        S_Model["defaultModel"]
        S_Theme["theme"]
        S_Lang["language"]
        S_Server["serverUrl"]
    end
    
    subgraph Server["服务器端"]
        WS_Config[".openwork/config.json"]
        OC_Config["opencode.json"]
    end
    
    LS_Model --> S_Model
    LS_Theme --> S_Theme
    LS_Lang --> S_Lang
    LS_Server --> S_Server
    
    WS_Config -.-> |"workspace"| Workspace
    OC_Config -.-> |"plugins/mcp"| Extensions
```

---

## 4. 会话交互流程

### 4.1 消息发送流程

```mermaid
sequenceDiagram
    participant User as 用户
    participant Composer as composer.tsx
    participant App as app.tsx
    participant Client as OpenCode Client
    participant Server as server.ts
    participant Engine as OpenCode Engine

    User->>Composer: 输入 prompt
    Composer->>App: 提交消息
    App->>App: setBusy(true)
    App->>Client: session.promptAsync()
    Client->>Server: HTTP 请求
    Server->>Engine: 转发请求
    
    Engine-->>Server: SSE 事件流
    Server-->>Client: 事件推送
    Client->>App: 处理事件
    
    alt session.updated
        App->>App: 更新 sessions
    end
    
    alt message.updated
        App->>App: 更新 messages
    end
    
    alt todo.updated
        App->>App: 更新 todos
    end
    
    alt permission.asked
        App->>User: 显示权限请求
    end
    
    Engine-->>Server: 完成
    Server-->>Client: 结束
    Client-->>App: 任务完成
    App->>App: setBusy(false)
```

### 4.2 服务器连接流程

```mermaid
sequenceDiagram
    participant User as 用户
    participant App as app.tsx
    participant Context as server context

    alt Host 模式
        User->>App: 选择 Host 模式
        App->>App: 启动本地服务器
        App->>Server: bun run packages/server/src/cli.ts
        Server->>App: 监听端口
    else Client 模式
        User->>App: 选择 Client 模式
        App->>User: 输入服务器 URL
        User->>App: 输入 Token
    end
    
    App->>Context: setServerUrl(url)
    App->>Context: setAuthToken(token)
    App->>Context: connect()
    
    Context->>Server: GET /health
    Server-->>Context: OK
    
    Context->>App: setConnected(true)
    App->>App: 加载工作区/会话
```

---

## 5. 组件关系图

### 5.1 app.tsx 组件树

```mermaid
flowchart TB
    subgraph App["app.tsx"]
        subgraph Modals["全局 Modals"]
            M_Model["model-picker-modal"]
            M_Reset["reset-modal"]
            M_MCP["mcp-auth-modal"]
            M_Provider["provider-auth-modal"]
            M_Lang["language-picker-modal"]
            M_CreateWS["create-workspace-modal"]
            M_RenameWS["rename-workspace-modal"]
            M_CreateRemote["create-remote-workspace-modal"]
            M_Share["share-workspace-modal"]
        end
        
        subgraph Views["Views"]
            V_Onboarding["onboarding.tsx"]
            V_Dashboard["dashboard.tsx"]
            V_Session["session.tsx"]
            V_Settings["settings.tsx"]
            V_Skills["skills.tsx"]
            V_Scheduled["scheduled.tsx"]
            V_Extensions["extensions.tsx"]
            V_Plugins["plugins.tsx"]
            V_MCP["mcp.tsx"]
            V_Identities["identities.tsx"]
            V_Config["config.tsx"]
            V_Soul["soul.tsx"]
        end
    end
    
    App --> Modals
    App --> Views
```

### 5.2 Session 组件

```mermaid
flowchart TB
    subgraph SessionView["session.tsx"]
        Composer["composer.tsx<br/>消息输入"]
        MessageList["message-list.tsx<br/>消息列表"]
        Sidebar["sidebar.tsx<br/>侧边栏"]
    end
    
    subgraph Panels["Panels"]
        ContextPanel["context-panel.tsx<br/>上下文"]
        ArtifactsPanel["artifacts-panel.tsx<br/>产物"]
        InboxPanel["inbox-panel.tsx<br/>收件箱"]
        Minimap["minimap.tsx<br/>最小地图"]
    end
    
    subgraph Blocks["Blocks"]
        Thinking["thinking-block.tsx<br/>思考"]
        PartView["part-view.tsx<br/>消息部分"]
        Editor["artifact-markdown-editor.tsx<br/>编辑器"]
    end
    
    SessionView --> Composer
    SessionView --> MessageList
    SessionView --> Sidebar
    SessionView --> Panels
    MessageList --> Blocks
```

---

## 6. 服务器 API 图

### 6.1 API 端点

```mermaid
flowchart TB
    subgraph API["API 端点"]
        Health["GET /health"]
        
        subgraph Workspaces["工作区"]
            ListWS["GET /workspaces"]
            CreateWS["POST /workspaces"]
            GetWS["GET /workspaces/:id"]
            DeleteWS["DELETE /workspaces/:id"]
        end
        
        subgraph Sessions["会话"]
            ListSessions["GET /sessions"]
            CreateSession["POST /sessions"]
            GetSession["GET /sessions/:id"]
        end
        
        subgraph Skills["技能"]
            ListSkills["GET /skills"]
            ImportSkill["POST /skills/import"]
        end
        
        subgraph Scheduler["定时任务"]
            ListJobs["GET /scheduler/jobs"]
            CreateJob["POST /scheduler/jobs"]
        end
        
        subgraph MCP["MCP"]
            ListMCP["GET /mcp"]
            AddMCP["POST /mcp"]
        end
    end
    
    Health --> ListWS
    ListWS --> CreateWS
    ListWS --> GetWS
    ListWS --> DeleteWS
    ListWS --> ListSessions
    ListSessions --> CreateSession
    ListSessions --> GetSession
    ListWS --> ListSkills
    ListSkills --> ImportSkill
    ListWS --> ListJobs
    ListJobs --> CreateJob
    ListWS --> ListMCP
    ListMCP --> AddMCP
```

---

## 7. 权限架构图

### 7.1 认证层级

```mermaid
flowchart TB
    subgraph Auth["认证层级"]
        Global["全局认证<br/>服务器 Token<br/>OAuth"]
        Workspace["工作区认证<br/>工作区 Token<br/>邀请链接"]
        Session["会话认证<br/>文件访问<br/>命令执行"]
    end
    
    Global --> Workspace
    Workspace --> Session
```

---

## 8. 部署架构图

### 8.1 部署模式

```mermaid
flowchart LR
    subgraph Desktop["桌面应用"]
        App["packages/app<br/>Tauri"]
    end
    
    subgraph SelfHosted["自托管"]
        Server["packages/server<br/>Bun"]
        Engine["OpenCode Engine"]
    end
    
    subgraph Cloud["云端 (可选)"]
        CloudServer["托管服务"]
        CloudDB["数据库"]
    end
    
    App --> |"本地连接"| Server
    Server --> Engine
    App --> |"远程连接"| CloudServer
    CloudServer --> CloudDB
```

---

*本文档最后更新于 2026-02-24*
