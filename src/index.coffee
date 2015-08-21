
# log = (args...) -> console.log 'CNSPC:', args...

module.exports = (options) ->
  (teacup) ->
    originalMethods = {}
    do ->
      {render, renderContents, isSelector, parseSelector, normalizeArgs} = teacup
      originalMethods = {render, renderContents, isSelector, parseSelector, normalizeArgs}
      
    teacup.classStack = ['global', '_']

    teacup.render = (template, args...) ->
      for arg in args
        if arg.classNamespace then teacup.classStack[0] = arg.classNamespace
      originalMethods.render.call teacup, template, args...
    
    teacup.renderContents = (contents, rest...) ->
      isFunc = (typeof contents is 'function')
      teacup.classStack.push '_' if isFunc
      originalMethods.renderContents.call teacup, contents, rest...
      teacup.classStack.pop()    if isFunc
      
    teacup.isSelector = (string) ->
      string.length > 1 and string.charAt(0) in ['#', '.', '+']

    plusClassRegex = new RegExp '\\+([^\\#\\.\\+]+)', 'g'
    teacup.parseSelector = (selector) ->
      # log 'entr parseSelector', selector, teacup.classStack
      plusClass = plusClassRegex.exec selector
      selector = selector.replace plusClassRegex, ''
      if not (klass = plusClass?[1])
        originalMethods.parseSelector.call teacup, selector
        return
      teacup.classStack[teacup.classStack.length-1] = klass
      selector += '.'
      for klass in teacup.classStack when klass isnt '_'
        selector += klass + '-'
      # log 'exit parseSelector', selector, teacup.classStack
      originalMethods.parseSelector.call teacup, selector[0..-2]
      
