local QBCore = exports['qb-core']:GetCoreObject()

local inventory = exports.ox_inventory

local Debug = function()
    print("LINE:", debug.getinfo(2).currentline)
end

lib.callback.register('laundering:server:getWasherData', function(washer)
    local washer = washer
    data = {}
    data.id = washer
    data.amount = Config.washers[washer].amount
    return data
end)

RegisterNetEvent('laundering:server:updateData', function(oldAmount, newAmount, washer, remove)
    if remove == false then
        local washer = washer
        local newAmount = newAmount
        local oldAmount = oldAmount
        print(washer, newAmount)
        Config.washers[washer].amount = newAmount
        inventory:RemoveItem(source, 'black_money', oldAmount)
    elseif remove == true then
        Config.washers[washer].amount = newAmount
        inventory:AddItem(source, 'black_money', oldAmount)
    end
end)



RegisterNetEvent('laundering:server:loadInventory', function(washerId)
    inventory:RegisterStash(washerId..'washer', 'Washer', 1, 10000000, nil, false, vector3(0, 0, 0))
end)

RegisterNetEvent('laundering:server:startWash', function(washerId)
    local amount = inventory:GetItemCount(washerId..'washer', 'black_money')
    local washTime = amount * Config.TimePerBag
    print(washTime / 60)

    if amount >= 100 then
        inventory:ClearInventory(washerId..'washer')
        Config.washers[washerId].amount = amount
        Config.washers[washerId].endTime = os.time() + math.floor(washTime)
        Config.washers[washerId].seconds = washTime
        Config.washers[washerId].washing = true
        if math.floor(washTime/60) > 0 then
            TriggerClientEvent('laundering:notify', source, math.floor(washTime/60).." minutes until your laundry is done", 'fas fa-clock')
        else
            TriggerClientEvent('laundering:notify', source, washTime.." seconds left", 'fas fa-clock')
        end
    end
end)

RegisterNetEvent('laundering:server:openWasher', function(washerId)
    if not Config.washers[washerId].washing then
        TriggerClientEvent('laundering:client:openWasher', source, washerId)
    elseif os.time() >= Config.washers[washerId].endTime then
        finalAmount = Config.washers[washerId].amount * Config.washers[washerId].percentage
        inventory:AddItem(source, 'cash', finalAmount)
        Config.washers[washerId].endTime = 0
        Config.washers[washerId].seconds = 0
        Config.washers[washerId].washing = false
        Config.washers[washerId].amount = 0
    else
        local timeLeft = Config.washers[washerId].endTime - os.time()
        print(timeLeft)

        if math.floor(timeLeft/60) > 0 then
            TriggerClientEvent('laundering:notify', source, math.floor(timeLeft/60).." minutes left", 'fas fa-clock')
        else
            TriggerClientEvent('laundering:notify', source, timeLeft.." seconds left", 'fas fa-clock')
        end
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        for k,v in pairs(Config.washers) do
            if v.washing then
                print('washing')
                if v.endTime < os.time() then
                    --print('Play Sound')
                    TriggerClientEvent('InteractSound_CL:PlayWithinDistance', -1, v.coords, 10.0, 'washingmachinedone.ogg', 100.0)
                end
            end
        end
    end
end)