step 		= require 'stepc'
helpers = require './helpers'

module.exports = 
	latest: (cb) ->
		step.async(
			() ->
				options =
					uri: "http://search.npmjs.org/_view/updated?descending=true&limit=15&include_docs=false"
					method: 'GET'
				helpers.requestCollapse options, this
			(err, obj) ->
				helpers.jsonResponseHandler err, obj, cb
		)
	search: (req, cb) ->
		step.async(
			() ->
				search_term = req.body.search
				options =
					uri: "http://search.npmjs.org/_list/search/search?startkey=%22#{search_term}%22&endkey=%22#{search_term}ZZZZZZZZZZZZZZZZZZZ%22&limit=25"
					method: "GET"
				helpers.requestCollapse options, this
			(err, obj) ->
				helpers.jsonResponseHandler err, obj, cb
		)
	show: (req, cb) ->
		step.async(
			() ->
				package_id = req.params.id
				options =
					uri: "http://search.npmjs.org/api/#{package_id}"
					method: "GET"
				helpers.requestCollapse options, this
			(err, obj) ->
				helpers.showResponseHandler err, obj, cb
		)