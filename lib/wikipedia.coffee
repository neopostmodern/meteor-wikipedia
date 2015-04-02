API_BASE_URL = "wikipedia.org/w/api.php"

defaultOptions =
  languageCode: "en"
  secure: true

baseParameters =
  format: 'json'
  # origin: Meteor.absoluteUrl() #todo: enable CORS, https://www.mediawiki.org/wiki/Manual:CORS


baseQueryParameters = _.extend {}, baseParameters, {
  action: 'query'
  continue: '' # API says: Formatting of continuation data will be changing soon. To continue using the current formatting, use the 'rawcontinue' parameter. To begin using the new format, pass an empty string for 'continue' in the initial query.
}

summaryParameters = _.extend {}, baseQueryParameters, {
  prop: 'extracts'
  exintro: ''
}

articleParameters = _.extend {}, baseQueryParameters, {
  prop: 'extracts'
}

searchParameters = _.extend {}, baseParameters, {
  action: 'opensearch'
}

generateBaseUrl = (options) ->
  options = _.defaults (options ? {}), defaultOptions

  return (if options.secure then "https" else "http") + "://#{ options.languageCode }.#{ API_BASE_URL }"


baseGetTextForPageId = (pageId, options, parameters, callback) ->
  handleResult = (result) ->
    page = result.data.query.pages[pageId]

    if not page? or page.missing?
      throw new Meteor.Error 404, "Wikipedia page not found."

    return page.extract


  pageId = parseInt(pageId)

  if not Match.test pageId, Match.Integer
    throw new Meteor.Error 400, "Not a valid Wikipedia Page ID: #{ pageId }"

  url = generateBaseUrl(options)

  executeRequest url, parameters, handleResult, callback

executeRequest = (url, parameters, handleResult, callback) ->
  if callback?
    HTTP.get url, params: parameters, (error, result) ->
      callback error, handleResult result
  else
    handleResult HTTP.get url, params: parameters


wikipedia =
  getSummaryForPageId: (pageId, options, callback) ->
    parameters = _.extend { pageids: pageId }, summaryParameters

    baseGetTextForPageId(pageId, options, parameters, callback)

  getArticleForPageId: (pageId, options, callback) ->
    parameters = _.extend { pageids: pageId }, articleParameters

    baseGetTextForPageId(pageId, options, parameters, callback)

  search: (query, options, callback) ->
    options ?= {}

    handleResult = (result) ->
      data = result.data

      results = []
      for pageTitle, index in data[1]
        results.push(
          title: pageTitle
          description: data[2][index]
          url: data[3][index]
        )

      return results

    _.defaults options, limit: 10

    url = generateBaseUrl(options)
    parameters = _.extend { search: query, limit: options.limit }, searchParameters

    executeRequest url, parameters, handleResult, callback

  resolvePageTitleToId: (title, options, callback) ->
    options ?= {}

    handleResult = (result) ->
      pages = result.data.query.pages

      pageIds = _.keys(pages)

      if pageIds.length > 1
        throw new Meteor.Error 500, "Multiple Wikipedia pages with title '#{title}'"

      if pageIds[0] is '-1'
        throw new Meteor.Error 404, "No Wikipedia page with title '#{title}'"

      return pageIds[0]

    url = generateBaseUrl(options)
    parameters = _.extend { prop: "info", titles: title }, baseQueryParameters

    executeRequest url, parameters, handleResult, callback




@Wikipedia = wikipedia