# Module dependencies.
express = require 'express'
stylus  = require 'stylus'
routes  = require './routes'
assets  = require 'connect-assets'
app     = express.createServer();

# Configuration
app.use assets()
app.use express.cookieParser()
app.use express.session({secret: 'foo bar bat baz'})
app.use express.logger()
app.use express.bodyParser()
app.use express.query()
app.use express.methodOverride()
app.use express.favicon()
app.use express.csrf()
app.use express.static "#{__dirname}/public"
app.set 'view engine', 'jade'


# Routes
app.get  '/', routes.index
app.get  '/browse', routes.index
app.post '/search', routes.search
app.get  '/:id', routes.show

# Bind to a port
app.listen process.env.PORT or 1337, -> console.log "Listening on port %d in %s mode", app.address().port, app.settings.env
