npm_reg = require '../lib/npm-reg'

# ROUTES
exports.index = (req, res) ->
	npm_reg.latest (err, data) ->
		res.render 'index', { title: 'Latest Packages', token: req.session._csrf, data }

exports.search = (req, res) ->
	npm_reg.search req, (err, data) ->
		res.render 'search', { title: 'Search Results', token: req.session._csrf, data }

exports.show = (req, res) ->
	npm_reg.show req, (err, data) ->
		res.render 'package', { title: '', token: req.session._csrf, data }