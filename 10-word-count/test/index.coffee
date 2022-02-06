fs = require 'fs'
assert = require 'assert'
WordCount = require '../lib'


helper = (input, expected, done) ->
  pass = false
  counter = new WordCount()

  counter.on 'readable', ->
    return unless result = this.read()
    assert.deepEqual result, expected
    assert !pass, 'Are you sure everything works as expected?'
    pass = true

  counter.on 'end', ->
    if pass then return done()
    done new Error 'Looks like transform fn does not work'

  counter.write input
  counter.end()


describe '10-word-count', ->

  it 'should count a single word', (done) ->
    input = 'test'
    expected = words: 1, lines: 1, characters: 4, bytes: 4
    helper input, expected, done

  it 'should count words in a phrase', (done) ->
    input = 'this is a basic test'
    expected = words: 5, lines: 1, characters: 20, bytes: 20
    helper input, expected, done

  it 'should count quoted characters as a single word', (done) ->
    input = '"this is one word!"'
    expected = words: 1, lines: 1, characters: 19, bytes: 19
    helper input, expected, done
  
  it 'should count camel cased words as multiple words', (done) ->
    input = 'this is a FunPuzzle'
    expected = words: 5, lines: 1, characters: 19, bytes: 19
    helper input, expected, done

  describe 'count lines', ->

    it 'should count file with only 1 line', (done) ->
      fs.readFile "#{__dirname}/fixtures/1,9,44.txt", 'utf8', (err, data) ->    
        expected = words: 9, lines: 1, characters: 44, bytes: 44
        helper data, expected, done

    it 'should count file with multiple lines and count quoted characters as a single word', (done) ->
      fs.readFile "#{__dirname}/fixtures/3,7,46.txt", 'utf8', (err, data) ->    
        expected = words: 7, lines: 3, characters: 46, bytes: 46
        helper data, expected, done

    it 'should count file with multiple lines and count camel cased words as multiple words', (done) ->
      fs.readFile "#{__dirname}/fixtures/5,9,40.txt", 'utf8', (err, data) ->    
        expected = words: 9, lines: 5, characters: 40, bytes: 40
        helper data, expected, done

  # Make the above tests pass and add more tests!
  it 'should return correct results for an empty string', (done) ->
    input = ''
    expected = words: 0, lines: 0, characters: 0, bytes: 0
    helper input, expected, done
  
  # ASSUMPTION: EMPTY LINES WILL NOT BE COUNTED
  it 'should ignore empty lines', (done) ->
    fs.readFile "#{__dirname}/fixtures/4,8,35.txt", 'utf8', (err, data) ->    
      expected = words: 8, lines: 4, characters: 36, bytes: 36
      helper data, expected, done

  # ASSUMPTION: ONE EMOJI WILL BE COUNTED AS 1 WORD, UNLESS THE EMOJI IS DIRECTLY
  # NEXT TO ANOTHER WORD
  describe 'count bytes', ->
    it 'should count bytes (one emoji)', (done) ->
      input = '😂'
      expected = words: 1, lines: 1, characters: 2, bytes: 4
      helper input, expected, done

    it 'should count bytes (two emojis without space in between)', (done) ->
      input = '😂👍'
      expected = words: 1, lines: 1, characters: 4, bytes: 8
      helper input, expected, done

    it 'should count bytes (two emojis with space in between)', (done) ->
      input = '😂 👍'
      expected = words: 2, lines: 1, characters: 5, bytes: 9
      helper input, expected, done

    it 'should count bytes (emoji and word without space in between', (done) ->
      input = '😂bytes'
      expected = words: 1, lines: 1, characters: 7, bytes: 9
      helper input, expected, done

    it 'should count bytes (emoji and word with space in between)', (done) ->
      input = '😂 bytes'
      expected = words: 2, lines: 1, characters: 8, bytes: 10
      helper input, expected, done
    
    it 'should count bytes (with escape character)', (done) ->
      input = 'I\'m a string'
      expected = words: 3, lines: 1, characters: 12, bytes: 12
      helper input, expected, done