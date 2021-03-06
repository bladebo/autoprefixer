Value = require('../lib/autoprefixer/value')
utils = require('../lib/autoprefixer/utils')

describe 'Value', ->
  beforeEach ->
    @calc = new Value('calc', ['-o-'])
    @hacks = utils.clone Value.hacks

  afterEach ->
    Value.hachs = @hacks

  describe '.regexp()', ->

    it 'should cache regexp', ->
      Object.keys(Value.regexps).should.not.include('rg')
      Value.regexp('rg').should.eql Value.regexps.rg
      Object.keys(Value.regexps).should.include('rg')

  describe '.load()', ->

    it 'should load class by value', ->
      class Hacked
        @names = ['hacked', 'hhacked']
        constructor: (@name, @prefixes) ->
      Value.register(Hacked)

      hacked = Value.load('hacked', ['-o-'])
      hacked.should.be.an.instanceof(Hacked)
      hacked.name.should.eql 'hacked'
      hacked.prefixes.should.eql ['-o-']

      Value.load('hhacked').should.be.an.instanceof(Hacked)
      Value.load('b').should.be.an.instanceof(Value)

  describe 'check()', ->

    it 'should check value in string', ->
      @calc.check(value: 'calc(1px + 1em)'    ).should.be.true
      @calc.check(value: '1px calc(1px + 1em)').should.be.true
      @calc.check(value: '(calc(1px + 1em))'  ).should.be.true

      @calc.check(value: '-o-calc').should.be.false
      @calc.check(value: 'calced' ).should.be.false

  describe 'prefixed()', ->

    it 'should check prefixed value', ->
      regexp = @calc.prefixed('-o-')
      regexp.test('1px -o-calc(1px)').should.be.true
      regexp.test('1px calc(1px)').should.be.false

  describe 'addPrefix()', ->

    it 'should add prefix to value', ->
      @calc.addPrefix('-o-', '1px calc(1em)').should.eql '1px -o-calc(1em)'
      @calc.addPrefix('-o-', '1px,calc(1em)').should.eql '1px,-o-calc(1em)'
