const gulp = require('gulp');
const mainBowerFiles = require('main-bower-files');
const notifier = require('node-notifier');
const $ = require('gulp-load-plugins')();
const plumberConfig = { errorHandler: function(err) {
  $.util.log($.util.colors.red(err.toString()));
  notifier.notify({
    title: 'Error in ' + err.plugin,
    message: err.message,
    sound: true
  });
  this.emit('end');
}};

gulp.task('vendor', ['vendor-scripts','vendor-styles']);

gulp.task('vendor-scripts', () => {
  return gulp.src(['node_modules/@babel/polyfill/dist/polyfill.min.js'].concat(mainBowerFiles('**/*.js')))
  .pipe($.plumber(plumberConfig))
  .pipe($.size({ title: 'vendor-scripts', showFiles: true }))
  .pipe($.uglify({preserveComments:'license'}))
  .pipe($.concat('vendor.js'))
  .pipe(gulp.dest('dist/public'));
});

gulp.task('vendor-styles', () => {
  return gulp.src(mainBowerFiles('**/*.css',{overrides:{
    'bootstrap-sass': {ignore:true}
  }}))
  .pipe($.plumber(plumberConfig))
  .pipe($.concat('vendor.css'))
  .pipe(gulp.dest('dist/public'));
});
