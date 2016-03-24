local LIP = require 'LIP';

local combo = {"cmd", "alt", "ctrl"}
local comboRaw = 1835305
local shortCombo = {"cmd", "alt"}
local shortComboRaw = 1573160



function fileExists(name)
  local exists = false
  local f = io.open(name, "r")
  if f ~= nil then
    exists = true
    io.close(f)
  end
  return exists
end


-- Reload Config --
hs.hotkey.bind(combo, "R", function()
  hs.reload()
end)
hs.alert.show("Hammerspoon config loaded")



-- Screen split --
function splitScreen(dir, full)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if full then
    f.x = max.x; f.y = max.y; f.w = max.w; f.h = max.h
  end

  if dir == "left" then
    f.x = max.x
    f.w = max.w / 2
  elseif dir == "right" then
    f.x = max.x + (max.w / 2)
    f.w = max.w / 2
  elseif dir == "up" then
    f.y = max.y
    f.h = max.h / 2
  elseif dir == "down" then
    f.y = max.y + (max.h / 2)
    f.h = max.h / 2
  end

  win:setFrame(f)
end

hs.hotkey.bind(combo, "Left", function()
  splitScreen("left", true)
end)
hs.hotkey.bind(shortCombo, "Left", function()
  splitScreen("left", false)
end)

hs.hotkey.bind(combo, "Right", function()
  splitScreen("right", true)
end)
hs.hotkey.bind(shortCombo, "Right", function()
  splitScreen("right", false)
end)

hs.hotkey.bind(combo, "Up", function()
  splitScreen("up", true)
end)
hs.hotkey.bind(shortCombo, "Up", function()
  splitScreen("up", false)
end)

hs.hotkey.bind(combo, "Down", function()
  splitScreen("down", true)
end)
hs.hotkey.bind(shortCombo, "Down", function()
  splitScreen("down", false)
end)

hs.hotkey.bind(combo, "M", function()
  splitScreen("max", true)
end)



-- Safari user agent switching --
hs.hotkey.bind({"cmd", "alt", "ctrl"}, '7', function()
  hs.application.launchOrFocus("Safari")
  local safari = hs.appfinder.appFromName("Safari")

  local str_default = {"Develop", "User Agent", "Default (Automatically Chosen)"}
  local str_ie10 = {"Develop", "User Agent", "Internet Explorer 10.0"}
  local str_chrome = {"Develop", "User Agent", "Google Chrome — Windows"}

  local default = safari:findMenuItem(str_default)
  local ie10 = safari:findMenuItem(str_ie10)
  local chrome = safari:findMenuItem(str_chrome)

  if (default and default["ticked"]) then
    safari:selectMenuItem(str_ie10)
    hs.alert.show("IE10")
  end
  if (ie10 and ie10["ticked"]) then
    safari:selectMenuItem(str_chrome)
    hs.alert.show("Chrome")
  end
  if (chrome and chrome["ticked"]) then
    safari:selectMenuItem(str_default)
    hs.alert.show("Safari")
  end
end)



-- Window layout --
local laptopScreen = "Color LCD"
local windowLayout = {
  {"Safari",         nil, laptopScreen, hs.layout.left50,  nil, nil},
  {"Sublime Text 2", nil, laptopScreen, hs.layout.right50, nil, nil},
}

hs.hotkey.bind(combo, "L", function()
  hs.layout.apply(windowLayout)
end)



-- Caffeine replacement --
local awakeIcon = hs.image.imageFromPath(os.getenv("HOME") .. "/.hammerspoon/full.tiff")
local sleepyIcon = hs.image.imageFromPath(os.getenv("HOME") .. "/.hammerspoon/empty.tiff")

local caffeine = hs.menubar.new()

function setCaffeineDisplay(state)
  if state then
    caffeine:setIcon(awakeIcon)
  else
    caffeine:setIcon(sleepyIcon)
  end
end

function caffeineToggle()
  setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
  caffeine:setClickCallback(caffeineToggle)
  setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end



-- Defeat paste blocking --
hs.hotkey.bind(shortCombo, "V", function()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)



-- Play some tunes --
local pb
local pbControl
local pbDir = os.getenv("HOME") .. '/.config/pianobar/'
local stations = {}

if fileExists(pbDir .. 'stations.ini') then
  local config = LIP.load(pbDir .. 'stations.ini');
  stations = config.stations
end

function sendPianoBarCommand(cmd)
  if pb:isRunning() then
    os.execute( "echo '" .. cmd .. "' > " .. pbDir .. 'ctl' )
  end
end

function ensurePianoBarPipe()
  os.execute( 'if [[ ! -p ' .. pbDir .. 'ctl ]]; then mkfifo ' .. pbDir .. 'ctl; fi' )
end

function discardOutput(task, stdOut, stdErr)
  return true
end

function newPianoBar()
  ensurePianoBarPipe()
  pb = hs.task.new("/usr/local/bin/pianobar", discardOutput, discardOutput)
  pb:setCallback(newPianoBar)
end

function newPbControl()
  local menu = {
    { title = 'Play/Pause', fn = function() sendPianoBarCommand('p') end },
    { title = 'Next Track', fn = function() sendPianoBarCommand('n') end },
    { title = '-' }
  }

  for k, v in pairs(stations) do
    table.insert(menu, { title = v, fn = function() sendPianoBarCommand(k) end })
  end

  table.insert(menu, { title = "-" })
  table.insert(menu, { title = "Quit Pianobar", fn = quitPianoBar })

  pbControl = hs.menubar.new()
  pbControl:setTitle('pb')
  pbControl:setMenu(menu)
end

function quitPianoBar()
  pb:terminate()
  pbControl:delete()
end

newPianoBar()

hs.hotkey.bind(combo, "P", function()
  if pb:isRunning() then
    quitPianoBar()
  else
    pb:start()
    newPbControl()
  end
end)

hs.eventtap.new({hs.eventtap.event.types.NSSystemDefined}, function(event)
  local data = event:getRawEventData().NSEventData

  if data.subtype == 8 and data.modifierFlags == shortComboRaw then
    if data.data1 == 1051392 then
      -- Play/Pause key
      sendPianoBarCommand('p')
    elseif data.data1 == 1248000 then
      -- Next track key
      sendPianoBarCommand('n')
    end
  end
end):start()
