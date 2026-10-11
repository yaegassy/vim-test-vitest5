# vim-test-vitest5

A [vim-test](https://github.com/vim-test/vim-test) runner for [Vitest](https://vitest.dev/) 5+.

## Why

Since Vitest 5, `-t` (`--testNamePattern`) is matched against the test's full name with the suite chain and the test name joined by `' > '`:

```ts
describe('math', () => {
  test('adds', () => {})
})
// Vitest 5+ : full name is "math > adds"
// Vitest 4- : full name was "math adds"
```

vim-test's built-in `vitest` runner joins the names with a single space, so `:TestNearest` on a test inside `describe` matches nothing on Vitest 5 and every test is skipped.

```
vitest run -t 'math adds' math.test.ts      # built-in vitest runner -> no test matched on Vitest 5
vitest run -t 'math > adds' math.test.ts    # vitest5 runner
```

This plugin adds a `vitest5` runner that joins the names with `' > '`. Everything else behaves the same as the built-in `vitest` runner.

See also:

- https://vitest.dev/config/testnamepattern
- https://vitest.dev/guide/migration

## Requirements

- [vim-test](https://github.com/vim-test/vim-test)
- Vitest 5 or later in your project

## Installation

[vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'vim-test/vim-test'
Plug 'yaegassy/vim-test-vitest5'
```

## Configuration

Register the runner and select it for JavaScript:

```vim
let g:test#custom_runners = {'JavaScript': ['Vitest5']}
let g:test#javascript#runner = 'vitest5'
```

If you already have `g:test#custom_runners`, add `'Vitest5'` to its `'JavaScript'` list.

Lua (Neovim):

```lua
vim.g['test#custom_runners'] = { JavaScript = { 'Vitest5' } }
vim.g['test#javascript#runner'] = 'vitest5'
```

> [!NOTE]
> Vitest 4 or earlier still uses space-joined names. Use the built-in `vitest` runner (`let g:test#javascript#runner = 'vitest'`) for those projects.

### Options

The same kinds of options as other vim-test runners are available:

| Option                                   | Description                     | Default                                                                             |
|------------------------------------------|---------------------------------|-------------------------------------------------------------------------------------|
| `g:test#javascript#vitest5#options`      | Extra arguments per granularity | not set (no extra arguments)                                                        |
| `g:test#javascript#vitest5#executable`   | Command used to run Vitest      | not set (`node_modules/.bin/vitest` if it exists, then `npx vitest`, then `vitest`) |
| `g:test#javascript#vitest5#file_pattern` | Pattern for test files          | `'\v(__tests__/.*\|(spec\|test))\.(js\|jsx\|ts\|tsx)$'`                             |

Examples:

```vim
let g:test#javascript#vitest5#options = {
  \ 'nearest': '--reporter=verbose',
  \}

let g:test#javascript#vitest5#executable = 'pnpm vitest'

let g:test#javascript#vitest5#file_pattern = '\v(__tests__/.*|(spec|test))\.(js|jsx|ts|tsx)$'
```

## Limitations

- `it.each` / `test.each` have the same limitations as the built-in runner: a multi-line `it.each([...])('...')` is not detected as the nearest test, and placeholders such as `%s` or `%d` in the name do not match the expanded test names.
- A test name containing `' > '` cannot be told apart from the separator. For example, both tests below have the same full name `a > b > c`, so `:TestNearest` on either of them runs both:

  ```ts
  describe('a', () => {
    test('b > c', () => {}) // full name: a > b > c
  })
  describe('a > b', () => {
    test('c', () => {}) // full name: a > b > c
  })
  ```

## License

MIT
