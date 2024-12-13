local hud = false
local speedometer = false

RegisterNUICallback('ready', function(data, cb)
    if data.show then 
        Wait(500)
        SendNUIMessage({
            action = 'show'
        })
        hud = true
    end
end)

local last = {
    health = -1,
    armour = -1,
    food = -1,
    water = -1,
    fuel = -1,
    speed = -1,
    pause = false
}

if not Config.ESX then
    RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
        food = newHunger
        water = newThirst
    end)
end

Citizen.CreateThread(function()
    while true do
        if hud then
            local pause = IsPauseMenuActive()
            if pause ~= last.pause then
                if pause then
                    SendNUIMessage({action = 'hide', opacity = 0})
                else
                    SendNUIMessage({action = 'hide', opacity = 1})
                end
                last.pause = pause
            end
            local player = PlayerPedId()
            local health = GetEntityHealth(player) - 100
            local armour = GetPedArmour(player)
            if Config.ESX then
                TriggerEvent('esx_status:getStatus', 'hunger', function(status) food = status.val / 10000 end)
                TriggerEvent('esx_status:getStatus', 'thirst', function(status) water = status.val / 10000 end)
            end
            if health < 0 then health = 0 end
            if health ~= last.health then SendNUIMessage({action = 'health', health = health}) last.health = health end
            if armour ~= last.armour then SendNUIMessage({action = 'armour', armour = armour}) last.armour = armour end
            if food ~= last.food then SendNUIMessage({action = 'food', food = food}) last.food = food end
            if water ~= last.water then SendNUIMessage({action = 'water', water = water}) last.water = water end
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 1000
        if hud then
            local player = PlayerPedId()
            if IsPedInAnyVehicle(player) then
                local vehicle = GetVehiclePedIsIn(player)
                if GetPedInVehicleSeat(vehicle, -1) == player then
                    wait = 200
                    if not speedometer then
                        SendNUIMessage({action = 'speedometer', speedometer = 'show', metric = Config.Metric})
                        speedometer = true
                    else
                        local fuel = GetVehicleFuelLevel(vehicle)
                        local speed = GetEntitySpeed(vehicle)
                        if fuel ~= last.fuel then SendNUIMessage({action = 'fuel', fuel = fuel}) last.fuel = fuel end
                        if speed ~= last.speed then SendNUIMessage({action = 'speed', speed = speed}) last.speed = speed end
                    end
                elseif speedometer then
                    SendNUIMessage({action = 'speedometer', speedometer = 'hide', metric = Config.Metric})
                    speedometer = false
                end
            elseif speedometer then
                SendNUIMessage({action = 'speedometer', speedometer = 'hide', metric = Config.Metric})
                speedometer = false
            end
        elseif speedometer then
            SendNUIMessage({action = 'speedometer', speedometer = 'hide', metric = Config.Metric})
            speedometer = false
        end
        Citizen.Wait(wait)
    end
end)

RegisterNetEvent('esx:playerLoaded', function()
    local defaultAspectRatio = 1920 / 1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio-aspectRatio) / 3.6) - 0.008
    end
    lib.requestStreamedTextureDict('squaremap')
    SetMinimapClipType(0)
    AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
    AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')
    -- 0.0 = nav symbol and icons left
    -- 0.1638 = nav symbol and icons stretched
    -- 0.216 = nav symbol and icons raised up
    SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)

    -- icons within map
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)

    -- -0.01 = map pulled left
    -- 0.025 = map raised up
    -- 0.262 = map stretched
    -- 0.315 = map shorten
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetBigmapActive(true, false)
    SetMinimapClipType(0)
    Wait(50)
    SetBigmapActive(false, false)
        showCircleB = false
        showSquareB = true
    Wait(1200)
end)

CreateThread(function()
    DisplayRadar(false)
    Wait(0)
end)

function seatbelt(toggle)
    SendNUIMessage({action = 'seatbelt', seatbelt = toggle})
end
