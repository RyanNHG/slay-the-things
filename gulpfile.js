var gulp = require('gulp'),
    watch = require('gulp-watch'),
    elm = require('gulp-elm'),
    nodemon = require('gulp-nodemon')

var paths = {
    elm: {
        main: './src/Main.elm',
        input: './src/*.elm',
        output: {
            directory: 'public/js/',
            filename: 'main.js'
        }
    }
}

var elmOptions = {
    dev: {
        debug: true
    },
    prod: {

    }
}

gulp.task('elm-make', elm.init)

gulp.task('elm', ['elm-make'], () => {
  
  gulp.src(paths.elm.main)
    .pipe(elm.bundle(paths.elm.output.filename, elmOptions.dev))
    .on('error', console.error)
    .pipe(gulp.dest(paths.elm.output.directory))

})

gulp.task('build:elm', ['elm-make'], () => {
  
  gulp.src(paths.elm.main)
    .pipe(elm.bundle(paths.elm.output.filename, elmOptions.prod))
    .on('error', console.error)
    .pipe(gulp.dest(paths.elm.output.directory))

})

gulp.task('watch:elm', ['elm'], () => {

    gulp.watch(paths.elm.input, ['elm'])

})

gulp.task('watch:server', () => {

    nodemon({
        script: 'app.js',
        ext: 'js',
        env: { 'NODE_ENV': 'development' }
    })

})

gulp.task('build', ['build:elm'])

gulp.task('watch', ['watch:elm', 'watch:server'])

gulp.task('default', ['build'])
