local QBCore = exports['qb-core']:GetCoreObject()

local target = exports.ox_target
local inventory = exports.ox_inventory

local magic = true

local Debug = function()
    print("LINE:", debug.getinfo(2).currentline)
end

local washers = Config.washers

--[[local function openWasher(washer)
    lib.callback('laundering:server:getWasherData', false, function(data)
        data = data
        lib.registerContext({
            id = washer.."washerMenu",
            title = "Washer",
            options = {
                {
                    title = 'Current Money',
                    description = '$'..inventory:GetItemCount('black_money'),
                    icon = 'money-bill-1-wave',
                    disabled = true,
                },
                {
                    title = 'Loaded Money',
                    description = '$'..data.amount,
                    icon = 'money-bill-1-wave',
                    disabled = true,
                },
                {
                    title = 'Start washer',
                    icon = 'power-off',
                    onSelect = function()
                        print('Washer Started')
                    end
                },
                {
                    title = 'Load Money',
                    onSelect = function()
                        local input = lib.inputDialog('Load Dirty Money', {'Amount'})
                        if not input then return end
                        if tonumber(input[1]) > inventory:GetItemCount('black_money') then
                            return QBCore.Functions.Notify('You don\'t have enough dirty money!', nil, 5000, 'fas fa-money-bill-1-wave')
                        end
                        print(input[1])
                        local newAmount = input[1] + data.amount
                        TriggerServerEvent('laundering:server:updateData', input[1], newAmount, data.id, false)
                    end
                },
                {
                    title = 'Remove Money',
                    onSelect = function()
                        local input = lib.inputDialog('Remove Dirty Money', {'Amount'})
                        if not input then return end
                        if (tonumber(data.amount) - input[1]) < 0 then
                            return QBCore.Functions.Notify('Too much!', nil, 5000, 'fas fa-money-bill-1-wave')
                        end
                        print(input[1])
                        local newAmount = data.amount - input[1]
                        TriggerServerEvent('laundering:server:updateData', input[1], newAmount, data.id, true)
                    end
                }

            }
        })
        lib.showContext(washer.."washerMenu")
    end, washer)
end]]

RegisterNetEvent('laundering:client:openWasher', function(washer)
    print(washer)
        lib.registerContext({
            id = washer.."washerMenu",
            title = "Washer",
            options = {
                {
                    title = 'Access Washer',
                    icon = 'box-open',
                    onSelect = function()
                        print(washer)
                        if inventory:openInventory('stash', washer..'washer') == false then
                            TriggerServerEvent('laundering:server:loadInventory', washer)
                            Wait(100)
                            inventory:openInventory('stash', washer..'washer')
                        end
                    end,
                },
                {
                    title = 'Start Washer',
                    icon = 'power-off',
                    onSelect = function()
                        TriggerServerEvent('laundering:server:startWash', washer)
                    end
                },

            }
        })
        lib.showContext(washer.."washerMenu")
end)

local function setTargets(bool)
    for k,v in pairs(washers) do
        --[[k = target:addBoxZone({
            coords = v.coords,
            size = v.size,
            rotation = v.heading,
            debug = magic,
            drawSprite = true,
            options = {
                {
                    label = 'Open washer',
                    name = k,
                    icon = 'fas fa-hand-point-right',
                    distance = 2.0,
                    onSelect = function()
                        TriggerServerEvent('laundering:server:openWasher', v.id)
                    end
                }
            }
        })]]
            k = target:addSphereZone({
                coords = v.coords,
                radius = v.radius,
                debug = magic,
                drawSprite = true,
                options = {
                    {
                        label = 'Open washer',
                        name = k,
                        --icon = 'fas fa-hand-point-right',
                        distance = 2.0,
                        onSelect = function()
                            TriggerServerEvent('laundering:server:openWasher', v.id)
                        end
                    }
                }
            })
    end
end

RegisterNetEvent('laundering:notify', function(text, icon)
    QBCore.Functions.Notify(text, nil, 5000, icon)
end)


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    setTargets()
end)

AddEventHandler('QBCore:Client:OnPlayerUnloaded', function()

end)