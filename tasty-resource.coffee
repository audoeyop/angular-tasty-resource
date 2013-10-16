# The MIT License (MIT)

# Copyright (c) 2013 Goran Sterjov

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class TastyResourceFactory

	constructor: (@$http, @_config)->
		@_config.cache ||= false


	query: (filter, success, error)->
		results = []

		url = @_config.url

		# construct the filter params
		filters = []
		for attr, value of filter
			filters.push "#{attr}=#{value}"

		url = "#{@_config.url}?#{filters.join('&')}" if filters.length > 0


		promise = @$http.get url, cache: @_config.cache

		promise.then (response)=>
			angular.copy(response.data.objects, results)
			results.meta = response.data.meta

		promise.then success, error
		results


	get: (id, success, error)->
		# if id has a leading slash then assume its a resource URI
		url = if id[0] is "/" then id else "#{@_config.url}#{id}"

		resource = new TastyResourceFactory(@$http, @_config)
		promise = @$http.get url, cache: @_config.cache

		promise.then (response)=>
			for key, value of response.data
				resource[key] = value

		promise.then success, error
		return resource


	post: ()->
		data = {}

		# get the post data
		for attr, value of @
			# filter out class features
			if typeof value != "function" and attr[0] not in ["$", "_"]
				# use the resource uri if the value is another resource
				if value instanceof TastyResourceFactory
					data[attr] = value.resource_uri
				else
					data[attr] = value

		promise = @$http.post @_config.url, data
		return promise



module = angular.module("tastyResource", [])

module.factory "TastyResource", ["$http", ($http)->
	(config)->
		new TastyResourceFactory($http, config)
]