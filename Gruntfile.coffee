# global module:false

module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    # Task configuration.
    jshint:
      options:
        curly: true
        eqeqeq: true
        immed: true
        latedef: true
        newcap: true
        noarg: true
        sub: true
        undef: true
        unused: true
        boss: true
        eqnull: true
        globals:
          jQuery: true

      lib_test:
        src: ['lib/**/*.js', 'test/**/*.js']
    nodeunit:
      files: ['test/**/*_test.js']
    watch:
      gruntfile:
        files: '<%= jshint.gruntfile.src %>'
        tasks: ['jshint:gruntfile']
      lib_test:
        files: '<%= jshint.lib_test.src %>'
        tasks: ['jshint:lib_test', 'nodeunit']

    coffeelint:
      app: ['app/*.coffee']

    nodemon:
      dev:
        script: 'app/app.coffee'
        args:['development  ']
        env:
          PORT:8081
    shell:
      mongo:
        command:'mongod'
        options:
          async: true

  # These plugins provide necessary tasks.
  tasks = [
    'grunt-contrib-nodeunit'
    'grunt-contrib-jshint'
    'grunt-contrib-watch'
    'grunt-coffeelint'
    'grunt-nodemon'
    'grunt-shell-spawn'
    ]

  for task in tasks
    grunt.loadNpmTasks task

  # Default task.
  grunt.registerTask 'default', ['coffeelint','jshint']
  grunt.registerTask 'dev', ['coffeelint', 'nodemon']
