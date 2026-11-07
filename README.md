## Respo workflow with Calcit

> A small Respo web application driven by [Calcit](https://github.com/calcit-lang/calcit)'s JavaScript backend.

Demo https://repo.calcit-lang.org/respo-calcit-workflow/ .

### Calcit 0.37.0 的使用者影响

CLI / `@calcit/procs` 配对正式 **0.37.0**，依赖使用 Reel **0.10.0**、UI **0.15.2**、Respo **0.19.5**、JS-FFI **0.2.13**，传递 Router **0.12.2**。
入口的 `:dispatch-op` 类型槽改为符号 `'app.types/Op`，0.37 不再接受字符串写法。

### 历史 Calcit 0.35.1 的使用者影响

CLI / `@calcit/procs` 配对正式 **0.35.1**，依赖使用已发布 Reel **0.9.2**、UI **0.15.1**、Respo **0.19.4**、JS-FFI **0.2.13**，传递 Router **0.12.1**。请重新安装完整依赖图、生成 JS 并刷新。新版 UI 可能影响基础样式。

输入回调接收名义 `RespoEvent`，分发使用宿主 `Op`。原 Reel 控制和旧存档仍通过受检解码进入应用。

新增业务状态游标只接受 Tag、字符串和数字，`CursorKey` union 在 Op、解码和组件读取三处保持一致；Bool 等非法元素会更早报错。状态 payload 仍是允许异构数据的真实边界，不用 union 假装所有业务字段都闭合。
Store 的根状态 key 也对齐 `CursorKey`，字符串和数字根路径不会在更新或恢复时又被仅 Tag 的旧限制拒绝。

启动先读取和恢复存档，再首次渲染和注册监听/保存。读取、解析、Store 解码或首次渲染失败经原 JS `hud!` 提示后中止；只有 key 真正缺失时才使用初始状态。原存储 key 和 wire 包装兼容保持。

Reel 0.8.0 的旧 Map API 改用 Option；本模板沿用 typed API，业务操作与历史算法不变。

官方事务规范旧类型声明；开发工具可选子节点改为显式 Option，关闭时不插入占位节点。保留原业务操作、存档格式与恢复失败保护、HUD、类型/质量预算和原测试；不修改生产/PR 预览路径，不新增校验脚本或强转。下文 0.30.0 的浏览器验收是历史记录，本轮验证结果以 PR 为准。

本模板的 default entry 明确为 JS/browser，`calcit` 默认生成前端代码。

内部 Reel 改为名义 `State<Op, Store>`，组件直接发单个 `:states` Op；
复制模板后新增业务操作时，应在 `app.types/Op`、`decode-op` 和 updater 中同步声明。
devtools 操作仍通过 Reel 自带的 `decode-control` 处理。未知业务操作会在入栈前报错，
不再记录一个无效的历史项。正常界面、输入、存储 key `workflow`、定时器与部署路径保留。

旧 Struct/Map 及历史单层 `:some Store` wire 包装在真实恢复边界解码；保存时取 Store 值，
不把 Option 本身强转后序列化。旧包装仅按 tag/arity 解包后验证 Store，不假装恢复了名义 Option。
启动时先成功恢复存储，再注册持久化监听和定时器；解析或解码失败时保留原值，不用初始 Store 覆盖。
初始空状态明确显示空字符串；不合法的已存字段报错，不以断言或强转绕过。
状态树仍是允许异构 payload 的容器，不能把静态指标为零理解为所有字段都已静态化。

此前 0.30.0 迁移删除旧 Map 回调适配器和两层临时解码 helper，不添加校验框架、concurrently 或
重复 COS 验证。原质量基线保留并将 schemaDynamic/unsafe 上限收紧至 0：完整 strict/preflight、190 个定义及一项针对
状态更新/序列化恢复的附着回归通过；schemaDynamic 和 unsafe 指标均为 0。
隔离浏览器已用合成文本验证输入、按钮、刷新恢复、Reel 面板、Reset 与保留状态的 HMR，
控制台无 error；依赖仍有一条未配置 `mode` 的既有 warning，不冒称零 warning。
旧包装保存→恢复→新格式保存后再次恢复也已在隔离浏览器通过。
测试仅在副本中启用 dev 模式、使用唯一存储 key，临时页面和进程已关闭。
上述为此前 0.30.0 迁移的验收，已经合入 main；0.35.1 与 0.37.0 的验收见各自 PR。

### Usages

To develop:

```bash
corepack enable && corepack prepare yarn@4.18.0 --activate
yarn install --immutable
caps --strict --ci
caps verify --toolchain

calcit -w calcit.cirru
yarn vite # watching and running on localhost:3000
```

`-w` 用于配置入口的持续运行，不与一次性的 `js` 子命令混用。
监听沿用 Calcit 的增量通知协议；用 CLI 修改 Snapshot 后，通过
`calcit edit inc --changed app.comp.container/comp-container` 等既有命令通知对应定义，
而不是假设直接改写 Snapshot 会自动被监听。编辑其他定义时替换为实际目标。
完整流程查看 `calcit docs read cli-options.md` 和 `calcit edit inc --help`，不额外增加 watcher 脚本。

To build:

```bash
yarn compile
yarn release
http-server dist/
```

### Workflow

https://github.com/calcit-lang/respo-calcit-workflow

### COS 静态资源部署实践

本项目的 [上传工作流](.github/workflows/upload.yaml) 是 Calcit/Respo 应用的完整示例；[worktools/cos-upload-action](https://github.com/worktools/cos-upload-action) 负责把已经构建好的目录上传到腾讯云 COS，并可经公开 CDN 对每个文件做字节数与 SHA-256 校验。项目仍保留自己的 Calcit 校验、Vite 构建、CDN 路径选择和原有服务器部署。

1. 在仓库或组织配置 `COS_BUCKET`、`COS_SECRET_ID`、`COS_SECRET_KEY` 三个 Actions secret。当前存储桶地域是 `ap-shanghai`，公开读取入口是 `https://cos-sh.tiye.me/`。COS 凭据仅授予目标桶所需的上传权限；外部 fork 和 Dependabot PR 仍完整安装、校验、测试与构建，但不执行 COS/rsync，因而没有远端预览。Dependabot 默认不能读取普通 Actions secrets，人工重跑也不改变原权限；不要为生成预览而复制生产部署密钥或改为执行不可信代码的 `pull_request_target`。普通可信 PR 和 main 仍需 COS 内置校验成功才部署，凭据缺失仍应失败，详见 [#58](https://github.com/calcit-lang/respo-calcit-workflow/issues/58)。
2. 构建前按目标路径设置 Vite base：生产环境为 `https://cos-sh.tiye.me/<owner>/<repo>/`，本项目的 PR 资源为 `https://cos-sh.tiye.me/<owner>/<repo>/pr/<pr-number>/<run-id>/<run-attempt>/`。`prefix`、Vite base 与 `public-base-url` 来自同一个目录输出，不能只改上传前缀而沿用旧 base。
3. 保留正式 v1.2.0 对应的固定 commit SHA 引用上传 Action，并传入 `source-dir: dist`、`bucket`、`region`、`prefix`、`public-base-url` 与三个 secret。Action 上传后会从公开 CDN 逐文件下载并比对字节数和 SHA-256，全部通过后才执行原有 rsync；项目不再复制远端验证脚本，COS 上传或公开读取失败也不会更新服务器上的 HTML。
4. COS 的 PR 资源按 PR 编号、运行和重试次数隔离，避免不同构建覆盖同名资源。原服务器 `/web-assets/repo/<owner>/<repo>/pr/` 共享预览入口保持不变，其 HTML 引用当次独立 COS 目录；生产 COS 前缀与原服务器路径也不变。CDN 校验的缓存参数与重试由 Action 内部处理，不再手动重复校验。长期使用运行级前缀时，应给旧对象设置存储桶生命周期清理策略。

验证顺序：先在同仓库 PR 中确认 Calcit 校验、构建、COS 上传和 CDN 读取全部成功，并检查 `dist/index.html` 的资源路径；合并后再检查 `main` 的生产前缀和原有服务器页面。不要仅凭上传命令成功就认为页面可用，也不要把 `dist/`、`js-out/` 等生成物提交到 Git。若出现 `AccessDenied`，先核对组织 secret 是否向该仓库开放、桶名是否包含 APPID、地域与前缀是否正确，再查看 COS 权限；若在上传前失败，应先修复原有构建，不能把失败归因于 COS。

迁移既有站点时可以先采用“影子上传”：保持 Vite base 和服务器部署不变，在原有 rsync **之后**额外上传到隔离的 COS 前缀，避免 COS 故障阻断现有生产部署，并通过 Action 的 `public-base-url` 校验逐文件验证。生产前缀覆盖同名文件时，CDN 可能短暂返回旧内容；Action 会对“下载加比对”整体做有限次数重试，每次使用不同的缓存参数。确认影子上传后再另行切换 Vite base 和页面部署；切换时则应先验证 CDN 资源，再更新服务器 HTML。上传 Action 的参数、校验和错误说明以其[中文文档](https://github.com/worktools/cos-upload-action#readme)为准。

已验证的两种迁移方式：[calcit-viewer 的隔离影子上传](https://github.com/calcit-lang/calcit-viewer/pull/53)保留了原页面部署，[Respo 示例](https://github.com/Respo/respo-example.calcit/pull/13)与 [cirru.org](https://github.com/Cirru/cirru.org/pull/47)也分别验证了其他组织的密钥和公开 CDN；[diary 的共享 Action 迁移](https://github.com/TopixIM/diary/pull/51)则保留已有的 CDN base、`/pr/` 预览与服务器部署，并在 PR 中通过 COS 上传和公开 CDN 检查。

### License

MIT
