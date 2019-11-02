local Rx = require 'rx'
local R = require("lamda")

local subject = Rx.Subject.create()
local scheduler = Rx.CooperativeScheduler.create()
local timerResolution = .25

subject:debounce(1.0,scheduler)
       :subscribe(function(x)
  print('observer a ' .. x)
end)

subject:delay(3,scheduler)
       :subscribe(function(x)
  print('observer b ' .. x)
end)

local function print_zip(value)
    return string.format("(%d,%d)",value[1],value[2])
end

local print_zip_lamda = R.compose(R.join(" "), R.map(tostring))

local szip = subject:zip(subject):map(function(...) return {...}end)

szip:map(R.map(function(a) return a + 1 end)):dump("zip-map-add",print_zip_lamda)
szip:map(R.all(R.equals(true))):dump("zip-map-and")
szip:dump("zip",print_zip)

subject:onNext(1)
subject(2)
subject:onNext(3)


-- Simulate 3 virtual seconds.
repeat
  scheduler:update(timerResolution)
until scheduler:isEmpty()

subject:onNext(4)

-- Simulate 3 virtual seconds.
repeat
  scheduler:update(timerResolution)
until scheduler:isEmpty()
