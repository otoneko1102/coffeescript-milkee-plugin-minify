# milkee-plugin-minify

This is a plugin for [milkee](https://www.npmjs.com/package/milkee) .

Minify plugin for milkee.

## Usage

### setup

#### coffee.config.cjs

```js
const plugin = require('milkee-plugin-minify');

module.exports = {
  // ...
  milkee: {
    plugins: [
      plugin(),
      // ...
    ]
  }
}
```

### Run

```sh
milkee
# or
npx milkee
```

## Options

You can pass options to the minifier via the plugin factory:

```js
const plugin = require('milkee-plugin-minify');

module.exports = {
  milkee: {
    plugins: [
      plugin({
        inPlace: true, // overwrite original files (default: true)
        suffix: '.min', // output suffix if not inPlace
        // Pass minify options for js/css/html/img
        options: {
          js: {
            type: 'terser',
            terser: { mangle: false }
          }
        }
        // or use minifyOptions instead of options (alias)
      })
    ]
  }
}
```

- `inPlace` (boolean): Overwrite original files (default: true)
- `suffix` (string): Suffix for output file if not inPlace
- `options` / `minifyOptions` (object): Passed to [minify](https://www.npmjs.com/package/minify) as options. See minify's README for available fields.
