gulp = require 'gulp'
gutil = require 'gulp-util'
mocha = require 'gulp-mocha'
runSequence = require 'run-sequence'

# compilers
coffee = require 'gulp-coffee'

gulp.task 'coffee', ->
  gulp.src './src/*.coffee'
    .pipe coffee()
    .pipe gulp.dest './lib'

gulp.task 'watch', ->
  gulp.watch './src/*.coffee', ['coffee']

gulp.task 'mocha', ->
  gulp.src './test/generate-test.coffee'
    .pipe mocha {reporter: 'spec'}

gulp.task 'default', ->
  runSequence 'coffee', 'mocha'

