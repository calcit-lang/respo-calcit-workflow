# Verify prebuilt caps setup / 验证预编译 caps 安装

- Upgrade the declared Calcit CLI and exact `@calcit/procs` dependency from `0.13.77` to `0.14.3`.
- Upgrade the Calcit modules to reel `0.6.19`, respo-ui `0.7.19`, and respo `0.16.96`; upgrade Vite to `8.2.2`. `bottom-tip` remains at its latest release, `0.1.5`.
- Upgrade to the published `setup-calcit@v1.5.0` release, which downloads and verifies the independent caps `0.1.1` Linux x64 release binary.
- Run the consumer workflow on `ubuntu-latest` and assert the resolved Calcit and caps versions before exercising dependency installation, toolchain verification, snapshot validation, JavaScript compilation, and the Vite production build.
- Keep the newest direct Respo releases despite their transient adjacent-patch transitive requests; run caps without strict warning rejection while retaining every subsequent verification step.
- Use Calcit 0.14's documented `--compat-types` migration mode for this existing example's legacy Dynamic schemas; leave the generated Snapshot unchanged and retain formatting, analysis, documentation, code generation, and production-build checks.

- 将声明的 Calcit CLI 与精确的 `@calcit/procs` 依赖从 `0.13.77` 升级到 `0.14.3`。
- 将 Calcit 模块升级至 reel `0.6.19`、respo-ui `0.7.19`、respo `0.16.96`，并将 Vite 升级至 `8.2.2`；`bottom-tip` 已是最新的 `0.1.5`。
- 升级到正式发布的 `setup-calcit@v1.5.0`；该版本会下载并校验独立发布的 caps `0.1.1` Linux x64 二进制。
- 在 `ubuntu-latest` 消费端 workflow 中先断言 Calcit 与 caps 版本，再执行依赖安装、toolchain 校验、Snapshot 验证、JavaScript 编译及 Vite 生产构建。
- 最新 Respo 直接依赖的传递依赖暂时仍声明相邻的旧补丁版本；保留所有最新直接依赖，关闭 caps 对解析警告的 strict 拒绝，同时保留后续全部验证步骤。
- 对该示例项目既有的 Dynamic schema 使用 Calcit 0.14 官方提供的 `--compat-types` 迁移模式；不改动生成的 Snapshot，并保留格式、分析、文档、代码生成及生产构建检查。
