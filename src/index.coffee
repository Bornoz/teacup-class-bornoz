module.exports = (options) ->
  (teacup) ->
    namespace = 'global'
    teacup.setNamespace = (namespaceIn) -> 
      namespace = namespaceIn
    
    originalMethods = {}
    do ->
      {renderContents, isSelector, parseSelector, normalizeArgs} = teacup
      originalMethods = {renderContents, isSelector, parseSelector, normalizeArgs}
      
    ###
    renderContents: (contents, rest...) ->
      if not contents?
        return
      else if typeof contents is 'function'
        result = contents.apply @, rest
        this.text result if typeof result is 'string'
      else
        this.text contents
    ###
    classStack = [namespace]
    
    teacup.renderContents: (contents, rest...) ->
      isFunc = (typeof contents is 'function')
      classStack.push '_' if isFunc
      originalMethods[renderContents].call teacup, contents, rest...
      classStack.pop()    if isFunc
      
    teacup.isSelector: (string) ->
      string.length > 1 and string.charAt(0) in ['#', '.', '+']

    ###
    parseSelector: (selector) ->
      id = null
      classes = []
      for token in selector.split '.'
        token = token.trim()
        if id
          classes.push token
        else
          [klass, id] = token.split '#'
          classes.push token unless klass is ''
      return {id, classes}
    ###
    
    plusClassRegex = new RegExp '\\+([^\\#\\.\\+]+)', 'g'
    teacup.parseSelector = (selector) ->
      plusClass = plusClassRegex.exec selector
      selector = selector.replace plusClassRegex, ''
      if not (klass = plusClass?[1])
        originalMethods[parseSelector].call teacup, selector
        return
      classStack[classStack.length-1] = klass
      selector += '.' + classStack.join '-'      
      originalMethods[parseSelector].call teacup, selector
      
