fs = require 'fs'
path = require 'path'
consola = require 'consola'
{ minify } = require 'minify'

pkg = require '../package.json'
PREFIX = "[#{pkg.name}]"

# Create a custom logger with prefix
c = {}
for method in ['log', 'info', 'success', 'warn', 'error', 'debug', 'start', 'box']
  do (method) ->
    c[method] = (args...) ->
      if typeof args[0] is 'string'
        args[0] = "#{PREFIX} #{args[0]}"
      consola[method] args...

# Main minify function
main = (compilationResult) ->
  { config, compiledFiles } = compilationResult

  pluginOptions = config?.milkee?.minify or {}
  inPlace = if pluginOptions.inPlace? then pluginOptions.inPlace else true
  suffix = pluginOptions.suffix ? ''
  filter = pluginOptions.filter ? (file) -> path.extname(file) == '.js' and not file.endsWith '.js.map'
  minifyOptions = if pluginOptions.options? then pluginOptions.options else if pluginOptions.minifyOptions? then pluginOptions.minifyOptions else {}

  filesToMinify = (compiledFiles or []).filter filter

  c.info "Minifying #{filesToMinify.length} file(s)"

  Promise.all (filesToMinify.map (file) ->
    # Skip if file is empty
    if fs.statSync(file).size is 0
      c.warn "Skip (empty): #{file}"
      return Promise.resolve()

    Promise.resolve().then ->
      minify file, minifyOptions
    .then (result) ->
      content = if typeof result is 'string' then result else if result? and result.js then result.js else String result

      outFile = if inPlace then file else path.join(path.dirname(file), path.basename(file, '.js') + suffix + '.js')

      fs.writeFileSync outFile, content, 'utf8'
      c.success "Minified -> #{outFile}"
    .catch (error) ->
      c.error "Failed to minify #{file}: #{error.message}"
      throw error
  )

# Export as a factory so users can pass options when requiring the plugin
module.exports = (options) ->
  (compilationResult) ->
    if options?
      config = compilationResult.config or {}
      config.milkee = config.milkee || {}
      config.milkee.minify = Object.assign {}, config.milkee.minify || {}, options
      compilationResult.config = config

    main compilationResult
