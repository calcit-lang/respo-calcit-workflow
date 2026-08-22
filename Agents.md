Developer runs `calcit js` for JavaScript build, and `yarn vite` to start the local server. LLMs should edit code through `calcit` commands, then trigger recompilation.

## 开工前必须看

先读通用 Calcit Agent 指南：

```bash
calcit docs agents --full
```

再看 Respo 模块用法：

```bash
calcit libs readme respo.calcit --file docs/Respo-Agent.md --full
```

## 高频命令

优先用查询命令定位，再做最小修改：

```bash
calcit query config
calcit query ns <ns>
calcit query defs <ns>
calcit query def <ns/def>
calcit query search '<keyword>' --filter '<ns/def>'
calcit tree show <ns/def> --path '<path>'
```

高频修改命令（`--code` 须用 `quote` 前缀）：

```bash
# 替换节点 — leaf 值用 quote |value，表达式用 quote (expr ...)
calcit tree replace <ns/def> --path '<path>' --code 'quote |new-value'
calcit tree replace <ns/def> --path '<path>' --code 'quote (new-expr ...)'

# 按内容搜索替换 leaf
calcit tree search-replace <ns/def> --pattern '<old>' --code 'quote |<new>'

# 从文件读取替换内容
calcit tree replace <ns/def> --path '<path>' --file snippet.cirru  # 内容须以 quote 开头

# 添加/更新定义
calcit edit def <ns/def> --code 'quote (defn my-fn () ...)'

# 添加 import
calcit edit add-import <ns> --code 'quote (src.ns :refer $ sym)'
```

高频验证命令：

```bash
calcit js
yarn vite
```

## 高频工作流

- 先定位再修改。先 `query def/search`，再 `tree show`，最后做 `tree replace` 或 `edit def`。
- 优先局部替换。不要整段重写 `calcit.cirru`，只改目标节点或小段结构。
- UI 改动和逻辑改动分开做，减少一次修改的影响面。
- 复杂结构先自检。尤其是 `let`、属性 map、嵌套列表、事件处理函数。
- 复用已有组件和样式。优先扩展现有 `defstyle`、组件和数据流，不重复造轮子。
- 每次改完都重新编译。默认先跑 `calcit js`，需要看界面再跑 `yarn vite`。

## 高频踩坑

- `let` 只保留最后一个表达式。多个表达式要包一层 `div` 或 `do`。
- 属性 map 必须成对。不要把 `:style`、`:inner-text` 等属性写进同一个 pair。
- `keys` 返回 set，不是 list。拼接前先 `.to-list`。
- 不要用 `.to-map` 处理 list of pairs，改用 `pairs-map`。
- 避免生成“可调用字符串”。错误写法如 `(<> ((str ...)))`，正确写法是 `<> $ str ...`。
- 变量必须保持 leaf。像 `week-start` 这种变量不要变成单元素 list，否则会被当成调用。
- Respo 样式里的纯数字会自动补 `px`。`flex`、`font-weight`、`line-height`、`z-index` 这类属性要显式写字符串，例如 `:flex "\"1"`。

## 修改约束

- 严禁直接手改 `calcit.cirru`，必须使用 `calcit tree` 或 `calcit edit`。
- 路径不要猜。先用 `calcit query search` 拿路径，再用 `calcit tree show` 确认。
- 静态样式优先抽到 `defstyle`，动态列表中尽量少写内联 `:style`。
- `--code` / `--file` 输入的 Cirru 代码必须用 `quote` 前缀包裹。
