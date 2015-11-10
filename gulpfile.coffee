# Site-specific variables
drush_alias = '@badev'
drush_command="/Users/iainhouston/drush8/vendor/bin/drush #{drush_alias} cr"
test_site_name = 'dev.bradford-abbas.uk:8888'
style_sources = './styles/**/*.styl'
coffee_sources = [ './coffee/*.coffee' ]
drupal_sources = [ './**/*.{php,theme,yml}' ]

# Workflow-specific variables
# ---------------------------
gulp = require('gulp')
argv = require('yargs').default('errorAction', 'fail').argv
gutil = require('gulp-util')
plumber = require('gulp-plumber')
autoprefixer = require('autoprefixer')
shell = require('gulp-shell')
lost = require('lost')
postcss = require('gulp-postcss')
stylus = require('gulp-stylus')
sourcemaps = require('gulp-sourcemaps')
browserSync = require('browser-sync').create()
reload = browserSync.reload

# Note whether, or not, errors should exit the gulp task with a non-zero return code
# as appropriate to development workflow or building a live site 
errorAction = argv.errorAction
gutil.log "Invoked with --errorAction=#{errorAction}"

# Compile to CSS
# --------------
gulp.task 'styles', ->
  processors = [ lost, autoprefixer(browsers: [ 'last 1 version' ]) ]
  gulp.src(style_sources).pipe(sourcemaps.init()).pipe(stylus()).pipe(postcss(processors)).pipe(sourcemaps.write('.')).pipe(gulp.dest('./css')).pipe reload(stream: true)

# Rebuild Drupal
# --------------
gulp.task 'drush', shell.task([ drush_command ])

# Watch for source changes in devleopment workflow
gulp.task 'serve_browser', ['styles', 'drush'], ->
  browserSync.init
    proxy: test_site_name
    reloadOnRestart: true
    browser: [ '/Applications/Google Chrome.app' ]
    # As we're testing we don't want compilation errors to kill gulp
  errorAction = 'noFail'
  gutil.log "errorAction overridden by serve_browser task. --errorAction='noFail'"

  gulp.watch style_sources, [ 'styles' ]
  gulp.watch drupal_sources, [ 'drush' ], reload
  return

# Error handler for styles and coffee
onError = (error) ->
  if errorAction == 'fail' 
    gutil.log "Compilation error encountered and treated as fatal."
    gutil.log error.message
    process.exit 1
  else
    gutil.beep()
    gutil.log error.message
  return true


# when no task is explicitly gulped
gulp.task 'default', [ 'serve_browser' ]
