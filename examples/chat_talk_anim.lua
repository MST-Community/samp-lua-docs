local sampev = require 'samp.events'

local TALK_ANIMATIONS = {
    { lib = "PED",   name = "IDLE_CHAT"      },
    { lib = "GANGS", name = "PRTIAL_GNGTLKM" },
    { lib = "GANGS", name = "PRTIAL_GNGTLKF" },
    { lib = "PHONE", name = "PHONE_TALK"     },
}

local BASE_MS     = 1500
local MS_PER_CHAR = 80
local MAX_MS      = 8000

local SPEED_THRESHOLD = 0.05
local MOVE_POLL_MS    = 100

local ANIM_SPEED  = 4.0
local ANIM_LOOP   = false
local ANIM_LOCK_X = false
local ANIM_LOCK_Y = false
local ANIM_LOCK_F = false
local ANIM_TIME   = -1

local animIndex = 1

local currentGen = 0

local function playerIsAlive()
    return not isCharDead(PLAYER_PED)
end

local function playerIsOnFoot()
    return isCharOnFoot(PLAYER_PED)
end

local function nextAnimIndex()
    animIndex = (animIndex % #TALK_ANIMATIONS) + 1
end

local function calcDuration(msg)
    return math.min(BASE_MS + #msg * MS_PER_CHAR, MAX_MS)
end

local function playAnim(lib, name)
    taskPlayAnim(
        PLAYER_PED, name, lib,
        ANIM_SPEED, ANIM_LOOP,
        ANIM_LOCK_X, ANIM_LOCK_Y, ANIM_LOCK_F,
        ANIM_TIME
    )
end

local function stopAnim()
    clearCharTasksImmediately(PLAYER_PED)
end

local function startWatcher(myGen, durationMs)
    lua_thread.create(function()
        local elapsed = 0

        while elapsed < durationMs do
            wait(MOVE_POLL_MS)
            elapsed = elapsed + MOVE_POLL_MS

            if currentGen ~= myGen then return end

            if not playerIsAlive() or not playerIsOnFoot() then
                break
            end

            if getCharSpeed(PLAYER_PED) > SPEED_THRESHOLD then
                break
            end
        end

        if currentGen == myGen then
            stopAnim()
        end
    end)
end

local function triggerTalkAnimation(message)
    if not playerIsAlive() then return end
    if not playerIsOnFoot() then return end

    currentGen = currentGen + 1
    local myGen = currentGen

    local anim     = TALK_ANIMATIONS[animIndex]
    local duration = calcDuration(message)
    nextAnimIndex()

    playAnim(anim.lib, anim.name)
    startWatcher(myGen, duration)
end

function sampev.onSendChat(message)
    if message and #message > 0 then
        triggerTalkAnimation(message)
    end
    return true
end


function main()
    while not isSampAvailable() do
        wait(100)
    end

    local loadedLibs = {}
    for _, anim in ipairs(TALK_ANIMATIONS) do
        if anim.lib ~= "PED" and not loadedLibs[anim.lib] then
            requestAnimation(anim.lib)
            loadedLibs[anim.lib] = true
        end
    end

    sampAddChatMessage("[Chat Talk Anim] v1.0.0 loaded.", 0x00FF88)

    while true do
        wait(0)
    end
end
