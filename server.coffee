# server.coffee

  # set up ========================
  express        = require 'express'
  app            = express()                 # create our app w/ express                                                   
  mongoose       = require 'mongoose'        # mongoose for mongodb                                                      
  morgan         = require 'morgan'          # log requests to the console (express4)                        
  bodyParser     = require 'body-parser'     # pull information from HTML POST (express4)
  methodOverride = require 'method-override' # simulate DELETE and PUT (express4)   

  # configuration =================

  mongoose.connect 'mongodb://aratnam:ratman@proximus.modulusmongo.net:27017/roR6ojan'   # connect to mongoDB database on modulus.io

  app.use(express.static __dirname + '/public')                 # set the static files location /public/img will be /img for users
  app.use(morgan 'dev')                                         # log every request to the console
  app.use(bodyParser.urlencoded {'extended':'true'})            # parse application/x-www-form-urlencoded
  app.use bodyParser.json                                       # parse application/json
  app.use(bodyParser.json { type: 'application/vnd.api+json' }) # parse application/vnd.api+json as json
  app.use methodOverride

  # define model =================
  Todo = mongoose.model 'Todo', {text: String}

  # routes ======================================================================

  # api ---------------------------------------------------------------------
  # get all todos
  app.get '/api/todos', (req, res) ->

      # use mongoose to get all todos in the database
      Todo.find (err, todos) ->

          # if there is an error retrieving, send the error. nothing after res.send(err) will execute
          res.send(err) if err

          # return all todos in JSON format
          res.json todos


  # create todo and send back all todos after creation
  app.post '/api/todos', (req, res) ->

      # create a todo, information comes from AJAX request from Angular
      Todo.create {
          text : req.body.text,
          done : false
      }, (err, todo) ->
          res.send err if err

          # get and return all the todos after you create another
          Todo.find (err, todos) ->
              res.send err if err  
              res.json todos;
          

  # delete a todo
  app.delete '/api/todos/:todo_id', (req, res) ->
      Todo.remove {
          _id : req.params.todo_id
      }, (err, todo) ->
          res.send err if err

          # get and return all the todos after you create another
          Todo.find (err, todos) ->
              res.send err if err
              res.json todos


  # application -------------------------------------------------------------
  app.get '*', (req, res) ->
      res.sendfile './public/index.html' # load the single view file (angular will handle the page changes on the front-end)              


  # listen (start app with node server.coffee) ======================================
  app.listen 8080
  console.log 'App listening on port 8080'