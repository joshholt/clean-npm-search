request = require 'request'

prettyDate = (time) ->
  time     = time.slice(0, time.indexOf('.'))+'Z' if time.indexOf '.'  != -1
  date     = new Date((time or "").replace(/-/g,"/").replace(/[TZ]/g," "))
  date     = new Date(date.getTime() - (date.getTimezoneOffset() * 1000 * 60))
  diff     = (((new Date()).getTime() - date.getTime()) / 1000)
  day_diff = Math.floor(diff / 86400)
  return "now" if day_diff == -1
  return day_diff + ' days ago' if day_diff >= 31
  return if isNaN(day_diff) or day_diff < 0 or day_diff >= 31
  if day_diff == 0
    if diff < 60
      return "just now"
    else if diff < 120
      return "1 minute ago"
    else if diff < 3600
      return "#{Math.floor(diff/60)} minutes ago"
    else if diff < 7200
      return "1 hour ago"
    else if diff < 86400
      return "#{Math.floor(diff/3600)} hours ago"
  else if day_diff == 1
    return "Yesterday"
  else if day_diff < 7
    return "#{day_diff} days ago"
  else if day_diff < 31
    return "#{Math.ceil(day_diff/7)} weeks ago"

isGithubUrl = (url) ->
  return url.slice(0, 'http://github.com'.length) == 'http://github.com' || url.slice(0, 'https://github.com'.length) == 'https://github.com' || url.slice(0, 'git://github.com'.length) == 'git://github.com'

exports.requestCollapse = (options, callback) ->
  request options, (error, response, body) ->
    callback error, {response, body}
  

exports.fixPackageDate = (package) ->
  package.package_date = prettyDate package.key
  return package

exports.jsonResponseHandler = (err, obj, cb) ->
  return cb err if err
  return cb "Error #{obj.response.statusCode} #{obj.body} #{err}" if not obj.response.statusCode == 200 
  self     = this
  data     = JSON.parse obj.body
  cb null, { total: data.total_rows, offset: data.offset, packages: (self.fixPackageDate package for package in data.rows) }

exports.searchResponseHandler = (err, obj, cb) ->
  return cb err if err
  return cb "Error #{obj.response.statusCode} #{obj.body} #{err}" if not obj.response.statusCode == 200 
  self     = this
  data     = JSON.parse obj.body
  cb null, data.rows

exports.showResponseHandler = (err, obj, cb) ->
	return cb err if err
	return cb "Error #{obj.response.statusCode} #{obj.body} #{err}" if not obj.response.statusCode == 200
	package = JSON.parse obj.body
	package.hasHomePage = false
	package.hasGitRepo  = false
	package.hasTime     = false
	package.hasAuthor   = false
	
	if package['dist-tags'] and package['dist-tags'].latest
		if package.versions[package['dist-tags'].latest].homepage
			package.hasHomePage = true
			package.home_page   = package.versions[package['dist-tags'].latest].homepage
	
	if typeof package.repository == "string"
		repositoryUrl = package.repository
		package.repository = 
		  type: if isGithubUrl repositoryUrl then 'git' else 'unknown'
		  url: repositoryUrl
		
	if package.repository and package.repository.type == 'git' and isGithubUrl(package.repository.url)
		package.hasGitRepo = true
		package.gitUrl = package.repository.url.replace('.git', '').replace('git://', 'https://')
		
	if package.time and package.time.modified
		package.hasTime = true
		package.lastUpdated = prettyDate(package.time.modified)
	
	if package.author and package.author.name
		authorName         = package.author.name
		package.hasAuthor  = true
		package.authorLink = "/author/#{authorName}"
		package.authorName = authorName
		
	cb null, package
	
