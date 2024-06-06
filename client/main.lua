local BANK = {
    Data = {}
}

local activeBlips, bankPoints, atmPoints, markerPoints = {}, {}, {}, {}
local playerLoaded, uiActive, inMenu = false, false, false

--Functions
    -- General data collecting thread
    function BANK:Thread()
        self:CreateBlips()
        local data = self.Data
        data.ped = PlayerPedId()
        data.coord = GetEntityCoords(data.Ped)
        playerLoaded = true

        if not Config.ShowMarker then return end

        CreateThread(function()
            local wait = 1000
            while playerLoaded do
                if next(markerPoints) then
                    for i = 1, #markerPoints do
                        DrawMarker(20, markerPoints[i].x, markerPoints[i].y, markerPoints[i].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, 187, 255, 0, 255, false, true, 2, false, nil, nil, false)
                    end
                    wait = 0
                end
                Wait(wait)
            end
        end)
    end

    -- Handle text ui / Keypress
    function BANK:TextUi(state, atm)
        uiActive = state
        if not state then
            return ESX.HideUI()
        end
        CreateThread(function()
            while uiActive do
                ESX.ShowHelpNotification(TranslateCap('press_e_banking'))
                if IsControlJustReleased(0, 38) then
                    self:HandleUi(true, atm)
                    self:TextUi(false)
                end
                Wait(0)
            end
        end)
    end

    -- Create Blips
    function BANK:CreateBlips()
        local tmpActiveBlips = {}
        for i = 1, #Config.Banks do
            if type(Config.Banks[i].Blip) == 'table' and Config.Banks[i].Blip.Enabled then
                local position = Config.Banks[i].Position
                local bInfo = Config.Banks[i].Blip
                local blip = AddBlipForCoord(position.x, position.y, position.z)
                SetBlipSprite(blip, bInfo.Sprite)
                SetBlipScale(blip, bInfo.Scale)
                SetBlipColour(blip, bInfo.Color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(bInfo.Label)
                EndTextCommandSetBlipName(blip)
                tmpActiveBlips[#tmpActiveBlips + 1] = blip
            end
        end

        activeBlips = tmpActiveBlips
    end

    -- Remove blips
    function BANK:RemoveBlips()
        for i = 1, #activeBlips do
            if DoesBlipExist(activeBlips[i]) then
                RemoveBlip(activeBlips[i])
            end
        end
        activeBlips = {}
    end

    -- Open / Close ui
    function BANK:HandleUi(state, atm)
        atm = atm or false
        SetNuiFocus(state, state)
        inMenu = state
        if not state then
            SendNUIMessage({
                type = 'open',
                showMenu = false
            })
            return
        end

        SendNUIMessage({type = "clear"})


        ESX.TriggerServerCallback("verexo:gethist", function(transactionHistory)
            for _, transaction in ipairs(transactionHistory) do
                SendNUIMessage({
                    type = 'historia',
                    time = transaction.time,
                    kwota = transaction.amount,
                    typ = transaction.type
                })
            end
        end)

        Citizen.Wait(100)

        SendNUIMessage({
            type = 'open',
            showMenu = true,
        })
        TriggerServerEvent("pobierzPieniadze")


        
    end

    function BANK:LoadNpc(index, netID)
        CreateThread(function()
            while not NetworkDoesEntityExistWithNetworkId(netID) do
                Wait(200)
            end
            local npc = NetworkGetEntityFromNetworkId(netID)
            TaskStartScenarioInPlace(npc, Config.Peds[index].Scenario, 0, true)
            SetEntityProofs(npc, true, true, true, true, true, true, true, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            FreezeEntityPosition(npc, true)
            SetPedCanRagdollFromPlayerImpact(npc, false)
            SetPedCanRagdoll(npc, false)
            SetEntityAsMissionEntity(npc, true, true)
            SetEntityDynamic(npc, false)
        end)
    end

-- Events
RegisterNetEvent('esx_banking:closebanking', function()
    BANK:HandleUi(false)
end)

RegisterNetEvent('esx_banking:pedHandler', function(netIdTable)
    for i = 1, #netIdTable do
        BANK:LoadNpc(i, netIdTable[i])
    end
end)



-- Handlers
    -- Resource starting
    AddEventHandler('onResourceStart', function(resource)
        if resource ~= GetCurrentResourceName() then return end
        BANK:Thread()
    end)

    -- Enable the script on player loaded 
    RegisterNetEvent('esx:playerLoaded', function()
        BANK:Thread()
    end)

    -- Disable the script on player logout
    RegisterNetEvent('esx:onPlayerLogout', function()
        playerLoaded = false
    end)

    -- Resource stopping
    AddEventHandler('onResourceStop', function(resource)
        if resource ~= GetCurrentResourceName() then return end
        BANK:RemoveBlips()
        if uiActive then BANK:TextUi(false) end
    end)

    RegisterNetEvent('esx:onPlayerDeath', function() BANK:TextUi(false) end)


function OpenAtm()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'open',
        showMenu = false,
        showPin = true,
    })
    TriggerServerEvent("pobierzPieniadze")

end

CreateThread(function()
    local options = {
        {
            name = 'banking:atm',
            icon = 'fa-sharp fa-solid fa-dollar-sign',
            label = 'Włóż karte',
            distance = 2,
            onSelect = function(data)
                OpenAtm()
            end,
        }
    }

    local models = {`prop_fleeca_atm`, `prop_atm_01`, `prop_atm_02`, `prop_atm_03`}

    exports.ox_target:addModel(models, options)
end)

CreateThread(function()
    for i = 1, #Config.Banks do
        exports.ox_target:addBoxZone({
            coords = Config.Banks[i].Position,
            size = vec3(2, 2, 2),
            rotation = 45,
            debug = drawZones,
            options = {
                {
                    name = 'banking:bank2',
                    icon = 'fa-sharp fa-solid fa-dollar-sign',
                    label = 'Skorzystaj z banku',
                    distance = 2,
                    onSelect = function(data)
                        BANK:HandleUi(true, false)
                    end,
                }
            }
        })
    end
end)

RegisterNUICallback("wyplac", function(data)
    local bankmon = tonumber(data.bankmoney)
    local bankacmoney = tonumber(data.bankaconmoney)
    print(bankmon)
    print(bankacmoney)
    if bankmon < bankacmoney then
        TriggerServerEvent("verexo:wyplac", bankmon, bankacmoney)
        TriggerServerEvent("pobierzPieniadze")
        TriggerServerEvent("refresh:server")
        TriggerServerEvent("verexo:updatehist")
       
    else
        ESX.ShowNotification("Nie możesz tego zrobić")
    end
end)
RegisterNUICallback("wyplacatm", function(data)
    local bankmon = tonumber(data.bankmoney)
    local bankacmoney = tonumber(data.bankaconmoney)
    print(bankmon)
    print(bankacmoney)
    if bankmon < bankacmoney then
        TriggerServerEvent("verexo:wyplacatm", bankmon, bankacmoney)
        TriggerServerEvent("pobierzPieniadze")
        TriggerServerEvent("refresh:server")
        TriggerServerEvent("verexo:updatehist")
        
        
    else
        ESX.ShowNotification("Nie możesz tego zrobić")
    end
end)


RegisterNUICallback("wplac", function(data)
    local bankmon = tonumber(data.bankmoney)
    local bankacmoney = tonumber(data.bankaconmoney)
    print(bankmon)
    print(bankacmoney)
    TriggerServerEvent("verexo:wplac", bankmon)
    TriggerServerEvent("pobierzPieniadze")
    TriggerServerEvent("refresh:server")
    
end)

RegisterNUICallback("transfer", function(data)
    local idplayer = tonumber(data.idtarget)
    local transfermoney = tonumber(data.kwotatransfer)
    print(idplayer)
    print(transfermoney)

    TriggerServerEvent("refresh:server")
    TriggerServerEvent("verexo:transfer", idplayer, transfermoney)
    TriggerServerEvent("pobierzPieniadze")
    
end)


RegisterNetEvent('refresh')
AddEventHandler('refresh', function()
	SendNUIMessage({type = "clear"})

    ESX.TriggerServerCallback("verexo:gethist2", function(transactionHistory)
        for _, transaction in ipairs(transactionHistory) do
            SendNUIMessage({
                type = 'historia',
                time = transaction.time,
                kwota = transaction.amount,
                typ = transaction.type
            })
        end
    end)
end)

RegisterNUICallback("uppin", function(data)
    local pin = tonumber(data.pin)

    TriggerServerEvent("verexo:uppin", pin)
end)

RegisterNUICallback("sprpin", function(data)
    local wppin = tonumber(data.wpispin)
    TriggerServerEvent("verexo:serversprpin", wppin)
   
end)



RegisterNUICallback("exit", function(data)
    
    SendNUIMessage({
        type = 'open',
        showMenu = false,
        showPin = false,
        
    })
    SetNuiFocus(false, false)
end)




RegisterNetEvent('aktualizujUI')
AddEventHandler('aktualizujUI', function(bankMoney, Money)
    SendNUIMessage({
        type = 'updateUI',
        money = Money,
        bankMoney = bankMoney
    })
end)



RegisterNetEvent('verexo:pinpoprawny')
AddEventHandler('verexo:pinpoprawny', function()
    print("verexo:pinpoprawny")
    SendNUIMessage({
        type = 'open',
        pinaccept = true
    })
end)
