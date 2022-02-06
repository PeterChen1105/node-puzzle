through2 = require 'through2'

byteSize = (str) -> 
  return encodeURI(str).split(/%(?:u[0-9A-F]{2})?[0-9A-F]{2}|./).length - 1

module.exports = ->
  words = 0
  lines = 0
  characters = 0
  bytes = 0

  transform = (chunk, encoding, cb) ->
    characters = chunk.length
    bytes = byteSize(chunk)

    allLines = chunk.split('\n')
    for line in allLines
      if line.length != 0
        lines++

        tokens = line.replace(/([a-z])([A-Z])/g, '$1 $2').split(' ')
        paired = true
        
        for token in tokens
          if token.startsWith('"')
            paired = false
            continue

          if paired
            words++
                
          else
            if token.endsWith('"')
              paired = true
              words++

    return cb()

  flush = (cb) ->
    this.push {words, lines, characters, bytes}
    this.push null
    return cb()

  return through2.obj transform, flush
