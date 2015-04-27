_ = require 'lodash'
cookie = require 'cookie'
Rx = require 'rx-lite'

class Cookies
  constructor: ->
    @cookieSubjects = {}
    @cookieConstructors = {}

  # Avoid triggering the cookieConstructor
  # Important because the {opts} for cookies are no longer accessible
  _set: (cookies) =>
    cookies = cookie.parse cookies or ''
    _.map cookies, (val, key) =>
      @cookieSubjects[key] = new Rx.BehaviorSubject(val)

  _getConstructors: => @cookieConstructors

  set: (key, value, opts) =>
    if @cookieSubjects[key]
      @cookieSubjects[key].onNext value
    else
      @cookieSubjects[key] = new Rx.BehaviorSubject(value)

    @cookieConstructors[key] = {
      value
      opts
    }
    if window?
      document.cookie = cookie.serialize key, value, opts

  get: (key) =>
    if @cookieSubjects[key]
      return @cookieSubjects[key]
    else
      @cookieSubjects[key] = new Rx.BehaviorSubject(null)
      return @cookieSubjects[key]

cookies = new Cookies()
module.exports = {
  _set: cookies._set
  _getConstructors: cookies._getConstructors
  set: cookies.set
  get: cookies.get
}