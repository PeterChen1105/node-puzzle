fs = require('fs')
readline = require('readline')

exports.countryIpCounter = (countryCode, cb) ->
  counter = 0

  rd = readline.createInterface(
    input: fs.createReadStream(__dirname + '/../data/geo.txt')
    console: false)

  rd.on 'line', (line) ->
    line = line.split('\u0009')
    if line[3] == countryCode
      counter += line[1] - (line[0])

  rd.on 'close', ->
    cb null, counter