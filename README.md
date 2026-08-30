## Respo workflow with Calcit

> A small Respo web application driven by [Calcit](https://github.com/calcit-lang/calcit)'s JavaScript backend.

Demo https://repo.calcit-lang.org/respo-calcit-workflow/ .

### Usages

To develop:

```bash
corepack enable && corepack prepare yarn@4.12.0 --activate
yarn install --immutable
caps --strict --ci
caps verify --toolchain

calcit -w calcit.cirru js
yarn vite # watching and running on localhost:3000
```

To build:

```bash
yarn compile
yarn release
http-server dist/
```

### Workflow

https://github.com/calcit-lang/respo-calcit-workflow

### License

MIT
