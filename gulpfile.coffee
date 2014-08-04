gulp = require 'gulp'
gutil = require 'gulp-util'
run = require 'gulp-run'

# compilers
coffee = require 'gulp-coffee'

gulp.task 'coffee', ->
  gulp.src './src/*.coffee'
    .pipe coffee()
    .pipe gulp.dest './lib'

gulp.task 'watch', ->
  gulp.watch './src/*.coffee', ['coffee']

gulp.task 'default', ['coffee'], ->
  run('npm test').exec()

