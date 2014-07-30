gulp = require 'gulp'
gutil = require 'gulp-util'
run = require 'gulp-run'

# compilers
coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'

gulp.task 'coffee', ->
  gulp.src './coffee/*.coffee'
    .pipe coffee()
    .pipe uglify()
    .pipe gulp.dest './'

gulp.task 'watch', ->
  gulp.watch './coffee/*.coffee', ['coffee']

gulp.task 'default', ['coffee'], ->
  run('npm test').exec()

