describe('scan', function()
  it('fails if the first argument is not a function', function()
    local observable = Rx.Observable.fromValue(0)
    expect(observable:scan()).to.fail()
    expect(observable:scan(1)).to.fail()
    expect(observable:scan('')).to.fail()
    expect(observable:scan({})).to.fail()
    expect(observable:scan(true)).to.fail()
  end)

  it('uses the seed as the initial value to the accumulator', function()
    local accumulator = spy()
    Rx.Observable.fromValue(3):scan(accumulator, 4):subscribe()
    expect(accumulator[1]).to.equal({4, 3})
  end)

  it('waits for 2 values before accumulating if the seed is nil', function()
    local accumulator = spy(function(x, y) return x * y end)
    local observable = Rx.Observable.fromTable({2, 4, 6}, ipairs):scan(accumulator)
    expect(observable).to.produce(8, 48)
    expect(accumulator).to.equal({{2, 4}, {8, 6}})
  end)

  it('uses the return value of the accumulator as the next input to the accumulator', function()
    local accumulator = spy(function(x, y) return x + y end)
    local observable = Rx.Observable.fromTable({1, 2, 3}, ipairs):scan(accumulator, 0)
    expect(observable).to.produce(1, 3, 6)
    expect(accumulator).to.equal({{0, 1}, {1, 2}, {3, 3}})
  end)

  it('passes all produced values to the accumulator', function()
    local accumulator = spy(function() return 0 end)
    local observable = Rx.Observable.fromTable({2, 3, 4}, ipairs, true):scan(accumulator, 0):subscribe()
    expect(accumulator).to.equal({{0, 2, 1}, {0, 3, 2}, {0, 4, 3}})
  end)

  it('calls onError if the accumulator errors', function()
    local onError = spy()
    Rx.Observable.fromRange(3):scan(error):subscribe(nil, onError, nil)
    expect(#onError).to.equal(1)
  end)
end)
