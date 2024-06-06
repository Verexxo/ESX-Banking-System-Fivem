local spawnedPeds, netIdTable = {}, {}

-- get keys utils
local function get_key(t)
    local key
    for k, _ in pairs(t) do
        key = k
    end
    return key
end

-- Resource starting
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if Config.EnablePeds then BANK.CreatePeds() end
    local twoMonthMs = (os.time() - 5259487) * 1000
    MySQL.Sync.fetchScalar('DELETE FROM banking WHERE time < ? ', {twoMonthMs})
end)

RegisterCommand("sprawdzczas", function()
    local copcccs = (os.time() - 5259487) * 1000

    print(copcccs)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if Config.EnablePeds then BANK.DeletePeds() end
end)

if Config.EnablePeds then
    AddEventHandler('esx:playerLoaded', function(playerId)
        TriggerClientEvent('esx_banking:pedHandler', playerId, netIdTable)
    end)
end





function logTransaction(targetSource,key,amount)
    if targetSource == nil then
        print("ERROR: TargetSource nil!")
        return
    end

    if key == nil then
        print("ERROR: Do you need use these: WITHDRAW,DEPOSIT,TRANSFER_RECEIVE")
        return
    end
    
    if type(key) ~= "string" or key == '' then
        print("ERROR: Do you need use these: WITHDRAW,DEPOSIT,TRANSFER_RECEIVE and can only be string type!")
        return
    end

    if amount == nil then
        print("ERROR: Amount value is nil! Add some numeric value to the amount!")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(tonumber(targetSource))

    if xPlayer ~= nil then
        local bankCurrentMoney = xPlayer.getAccount('bank').money
        BANK.LogTransaction(targetSource, string.upper(key), amount, bankCurrentMoney)  
    else
        print("ERROR: xPlayer is nil!") 
    end
end
exports("logTransaction", logTransaction)

-- bank functions
BANK = {
    
    CreatePeds = function()
        for i = 1, #Config.Peds do
            local model = Config.Peds[i].Model
            local coords = Config.Peds[i].Position
            spawnedPeds[i] = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, true, true)
            netIdTable[i] = NetworkGetNetworkIdFromEntity(spawnedPeds[i])
            while not DoesEntityExist(spawnedPeds[i]) do Wait(50) end
        end

        Wait(100)
        TriggerClientEvent('esx_banking:PedHandler', -1, netIdTable)
    end,
    DeletePeds = function()
        for i = 1, #spawnedPeds do
            DeleteEntity(spawnedPeds[i])
            spawnedPeds[i] = nil
        end
    end,
    LogTransaction = function(playerId, logType, amount, bankMoney)
        if playerId == nil then
            return
        end
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local identifier = xPlayer.getIdentifier()

        MySQL.insert('INSERT INTO banking (identifier, type, amount, time, balance) VALUES (?, ?, ?, ?, ?)',
            {identifier, logType, amount, os.time() * 1000, bankMoney})
    end   
}

ESX.RegisterServerCallback("verexo:gethist", function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.getIdentifier()
    local weekAgo = (os.time() - 604800) * 1000
    local transactionHistory = MySQL.Sync.fetchAll(
        'SELECT * FROM banking WHERE identifier = ? AND time > ? ', {identifier, weekAgo})

    -- Przesyłanie danych do klienta
    cb(transactionHistory)
end)

ESX.RegisterServerCallback("verexo:gethist2", function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.getIdentifier()
    local weekAgo = (os.time() - 604800) * 1000
    local transactionHistory = MySQL.Sync.fetchAll(
        'SELECT * FROM banking WHERE identifier = ? AND time > ? ', {identifier, weekAgo})
 
    -- Przesyłanie danych do klienta
    cb(transactionHistory)
end)


RegisterServerEvent("refresh:server")
AddEventHandler("refresh:server", function()
    TriggerClientEvent("refresh", source)
end)
RegisterServerEvent("verexo:serversprpin")
AddEventHandler("verexo:serversprpin", function(wppin)
    local _source = source
    

    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local pincode = MySQL.Sync.fetchScalar('SELECT pincode FROM users WHERE identifier = ?',
    {identifier})

    if pincode == nil then
        TriggerClientEvent("esx:showNotification", _source, "Nie masz ustawionego PIN-U", "error")
       
    else
        if wppin == pincode then
            TriggerClientEvent("esx:showNotification", _source, "Poprawny PIN", "error")
            TriggerClientEvent("verexo:pinpoprawny", _source)
        else
            TriggerClientEvent("esx:showNotification", _source, "Błędny PIN", "error")
        end
        
    end

    
end)

RegisterServerEvent("verexo:getaccount")
AddEventHandler("verexo:getaccount", function(bankmon, temat, bankacmoney)
        local xPlayer = ESX.GetPlayerFromId(source)
        local bankMoney = xPlayer.getAccount('bank').money
        local Money = xPlayer.getAccount('money').money
        TriggerClientEvent('verexo:updateBankMoney', bankMoney, Moeny)
end)

RegisterServerEvent("verexo:wyplac")
AddEventHandler("verexo:wyplac", function(bankmon, temat, bankacmoney)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(source)
       
        local bankMoney = xPlayer.getAccount('bank').money
        if bankmon <= bankmon then
            xPlayer.addAccountMoney('money', bankmon)
            xPlayer.removeAccountMoney('bank', bankmon)
            TriggerClientEvent('verexo:updateBankMoney', bankMoney)
            BANK.LogTransaction(source, string.upper("Wyplata"), bankmon, bankMoney)
            TriggerClientEvent("esx:showNotification", _source, "Wypłacono", "error")
            exports['Packv6_logs']:SendLog(source, 'Gracz '.. GetPlayerName(source) .. ' Wypłaćił '.. bankmon, 'wyplacanie')
            
        else
            TriggerClientEvent("esx:showNotification", _source, "Nie możesz tego zrobic", "error")
        end
      
end)
RegisterServerEvent("verexo:wyplacatm")
AddEventHandler("verexo:wyplacatm", function(bankmon, temat, bankacmoney)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(source)
       
        local bankMoney = xPlayer.getAccount('bank').money
        if bankmon <= bankmon then
            xPlayer.addAccountMoney('money', bankmon)
            xPlayer.removeAccountMoney('bank', bankmon)
            TriggerClientEvent('verexo:updateBankMoney', bankMoney)
            BANK.LogTransaction(source, string.upper("Wyplata"), bankmon, bankMoney)
            TriggerClientEvent("esx:showNotification", _source, "Wypłacono", "error")
            exports['Packv6_logs']:SendLog(source, 'Gracz '.. GetPlayerName(_source) .. ' Wypłaćił '.. bankmon, 'wyplacanie')
        else
            TriggerClientEvent("esx:showNotification", _source, "Nie możesz tego zrobic", "error")
        end
      
end)
RegisterServerEvent("verexo:transfer")
AddEventHandler("verexo:transfer", function(idplayer, transfermoney)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(idplayer)
    local bankMoney = xPlayer.getAccount('bank').money

    if idplayer > 0 and bankMoney >= transfermoney then
        if xTarget == nil or xPlayer.source == xTarget.source then
            TriggerClientEvent("esx:showNotification", _source, "Nie mozesz tego zrobic", "error")
            return false
        end
    
        xPlayer.removeAccountMoney('bank', transfermoney)
        xTarget.addAccountMoney('bank', transfermoney)
        local bankMoney = xTarget.getAccount('bank').money
        local amount = transfermoney
        BANK.LogTransaction(xTarget.source, string.upper("PRZELEW_P"),  amount, bankMoney)
        BANK.LogTransaction(xPlayer.source, string.upper("PRZELEW_W"),  amount, bankMoney)
        exports['Packv6_logs']:SendLog(source, 'Gracz '.. GetPlayerName(_source) .. ' przelał '.. transfermoney .. ' dla '.. GetPlayerName(idplayer), 'transfer')
        
    end
   

      
end)


RegisterServerEvent("verexo:wplac")
AddEventHandler("verexo:wplac", function(bankmon, temat, bankacmoney)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local item = xPlayer.getInventoryItem("money")
        if item.count >= bankmon then
            xPlayer.addAccountMoney('bank', bankmon)
            xPlayer.removeInventoryItem('money', bankmon)
            local bankMoney = xPlayer.getAccount('bank').money
            BANK.LogTransaction(source, string.upper("Wplata"), bankmon, bankMoney)
            TriggerClientEvent("esx:showNotification", _source, "Wpłacono", "error")
            exports['Packv6_logs']:SendLog(source, 'Gracz '.. GetPlayerName(_source) .. ' Wpłacił '.. bankmon, 'wplacanie')
        else
            TriggerClientEvent("esx:showNotification", _source, "Nie możesz tego zrobic", "error")  
        end
       
end)

RegisterServerEvent("verexo:uppin")
AddEventHandler("verexo:uppin", function(pin)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local identifier = xPlayer.getIdentifier()
        MySQL.update('UPDATE users SET pincode = ? WHERE identifier = ? ', {pin, identifier})
        TriggerClientEvent("esx:showNotification", _source, "Ustawiłes nowy Pin ("..pin..")", "error")
end)


RegisterServerEvent('pobierzPieniadze')
AddEventHandler('pobierzPieniadze', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local bankMoney = xPlayer.getAccount('bank').money
    local Money = xPlayer.getAccount('money').money

    TriggerClientEvent('aktualizujUI', _source, bankMoney, Money)
end)
