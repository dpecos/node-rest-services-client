request = require 'request'
Q = require 'q'

endpoint = null
services = null

buildServiceURL = (service, url_params) ->
  url = "https://#{endpoint.host}" if endpoint.https
  url = "http://#{endpoint.host}" unless endpoint.https

  url += services[service]

  url

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
    post: post
  }
