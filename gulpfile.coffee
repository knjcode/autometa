gulp = require 'gulp'
jshint = require 'gulp-jshint'
coffeelint = require 'gulp-coffeelint'
mocha = require 'gulp-mocha'
runSequence = require 'run-sequence'

# compilers
coffee = require 'gulp-coffee'

gulp.task 'coffee', ->
  gulp.src './src/*.coffee'
    .pipe coffee()
    .pipe gulp.dest './lib'

gulp.task 'coffeelint', ->
  gulp.src ['./src/*.coffee', './test/*.coffee']
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'jshint', ->
  gulp.src ['./bin/*.js', './lib/*.js']
    .pipe jshint()
    .pipe jshint.reporter()

gulp.task 'watch', ->
  gulp.watch './src/*.coffee', ['coffee']

gulp.task 'mocha', ->
  gulp.src './test/*.coffee'
    .pipe mocha {reporter: 'spec'}

gulp.task 'default', ->
  runSequence ['coffeelint', 'jshint'], 'coffee', 'mocha'

