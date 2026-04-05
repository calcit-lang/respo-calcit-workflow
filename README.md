## Respo workflow in Calcit-js

> Respo web page based on [calcit-js](https://github.com/calcit-lang/calcit).

Demo https://repo.calcit-lang.org/respo-calcit-workflow/ .

### Usages

To develop:

```bash
corepack enable && corepack prepare yarn@4.12.0 --activate
yarn install --immutable

cr js -w
yarn vite # watching and running on localhost:3000
```

calcit-js is using [Calcit Editor](https://github.com/calcit-lang/editor).

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
