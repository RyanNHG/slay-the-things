var gulp = require('gulp'),
    watch = require('gulp-watch'),
    elm = require('gulp-elm'),
    nodemon = require('gulp-nodemon')

var paths = {
    elm: {
        main: './Main.elm',
        input: './*.elm',
        output: {
            directory: 'public/js/',
            filename: 'main.js'
        }
    }
}

var elmOptions = {
    debug: (process.env.NODE_ENV !== 'production')
}

gulp.task('elm-make', elm.init)

gulp.task('elm', ['elm-make'], () => {
  
  gulp.src(paths.elm.main)
    .pipe(elm.bundle(paths.elm.output.filename, elmOptions))
    .pipe(gulp.dest(paths.elm.output.directory))

})

gulp.task('watch:elm', ['elm'], () => {

    watch(paths.elm.input, ['elm'])

})

gulp.task('watch:server', () => {

    nodemon({
        script: 'app.js',
        ext: 'js',
        env: { 'NODE_ENV': 'development' }
    })

})

gulp.task('build', ['elm'])

gulp.task('watch', ['watch:elm', 'watch:server'])

gulp.task('default', ['build'])
