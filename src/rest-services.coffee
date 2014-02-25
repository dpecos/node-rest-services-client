request = require 'request'
Q = require 'q'

endpoint = null
services = null

buildServiceURL = (service, url_params) ->
  url = "https://#{endpoint.host}" if endpoint.https
  url = "http://#{endpoint.host}" unless endpoint.https

  path = services[service]

  path = path.replace ":#{name}", value for name, value of url_params

  url += path

  url

get = (service, url_params) ->
  deferred = Q.defer()

  request_conf =
    uri: buildServiceURL(service, url_params)
  request_conf['auth'] = endpoint.auth if endpoint.auth

  request.get request_conf, (err, response, body) ->
    if err
      deferred.reject err
    else if response.statusCode isnt 200
      deferred.reject "HTTP Response code #{response.statusCode}"
    else
      deferred.resolve body

  deferred.promise

post = (service, url_params, data) ->
  deferred = Q.defer()

  request_conf =
    uri: buildServiceURL(service, url_params)
    headers:
      "content-type": "application/json"
    body: JSON.stringify(data)
  request_conf['auth'] = endpoint.auth if endpoint.auth

  request.post request_conf, (err, response, body) ->
    if err
      deferred.reject err
    else if response.statusCode isnt 200
      deferred.reject "HTTP Response code #{response.statusCode}"
    else
      deferred.resolve body

  deferred.promise

module.exports = (config) ->
  endpoint = config.endpoint
  services = config.services

  return {
    get: get
    post: post
  }
