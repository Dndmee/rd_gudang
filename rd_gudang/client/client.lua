local ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()


    playerIdent = ESX.GetPlayerData().identifier
	
end)

RNE('esx:setJob')
RNE('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

function LockerMenu(k, hasLocker, lockerName)
	local elements = {}
	
	if hasLocker then
		table.insert(elements, {
            header = 'Buka Gudang', 
            params = {
                event = "rd-openLocker"
                args = {
                    lokasi = k,
                    gudang = hasLocker,
                    namaGudang = lockerName
                }
            }
        })

		table.insert(elements, {
            header = 'Berhenti Rental Gudang', 
            params = {
                event = "rd-berhentiSewaGudang",
                args = {
                    lokasi = k,
                    namaGudang = lockerName
                }
            }
            value = 'stop_renting'})
	end
	
	if not hasLocker then
		table.insert(elements, {
            header = 'Sewa Gudang',
            txt = 'Biaya Sewa Awal: $'.. ESX.Math.GroupDigits(RD.InitialRentPrice)"<br>Biaya Bulanan: $".. ESX.Math.GroupDigits(RD.DailyRentPrice),
            params = {
                event = "rd-sewaGudang",
                args = {
                    lokasi = k,
                    namaGudang = lockerName
                }
            }
        })
    end
    exports['qb-menu']:openMenu(elements)

end

RNE("rd-sewaGudang", function(data)
    TriggerServerEvent('rd_gudang:startRentingLocker', data.lokasi, data.namaGudang)
end)

RNE("rd-openLocker", function(data)
    ESX.Streaming.RequestAnimDict('anim@heists@keycard@', function()
        TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "stashopen", 0.6)
        Citizen.Wait(500)
        ClearPedTasksImmediately(PlayerPedId())
    end)
    Openstashopen(data.lokasi, data.gudang, data.namaGudang)
end)

RNE("rd-berhentiSewaGudang", function(data)
    TriggerServerEvent('rd_gudang:stopRentingLocker', data.lokasi, data.namaGudang)
end)

function Openstashopen(lockerId, identifier, lockerName)
    local owner = ESX.GetPlayerData().identifier
    ESX.TriggerServerCallback("rd_gudang:getPropertyInventory", function(inventory)
        if exports.ox_inventory:openInventory('stash', {id=lockerName, owner=owner}) == false then
            TriggerServerEvent('gudang:registerstash', lockerName)
            exports.ox_inventory:openInventory('stash', {id=lockerName, owner=owner})
        end
		Wait(2000)
		LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
		TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
    end, identifier, lockerName)
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

RNE('rd_gudang:gudangkota')
AEH('rd_gudang:gudangkota', function ()
	ESX.TriggerServerCallback('rd_gudang:checkLocker', function(checkLocker)
		LockerMenu('locker1', checkLocker, 'Gudang Kota')
	end, 'locker1')
end)

RNE('rd_gudang:gudangss')
AEH('rd_gudang:gudangss', function ()
	ESX.TriggerServerCallback('rd_gudang:checkLocker', function(checkLocker)
		LockerMenu('locker3', checkLocker, 'Gudang Sandy Shores')
	end, 'locker3')
end)

RNE('rd_gudang:gudangpaleto')
AEH('rd_gudang:gudangpaleto', function ()
	ESX.TriggerServerCallback('rd_gudang:checkLocker', function(checkLocker)
		LockerMenu('locker2', checkLocker, 'Gudang Paleto')
	end, 'locker2')
end)


Citizen.CreateThread(function()
	exports.qtarget:AddBoxZone("gudangkota", vector3(-1607.59, -830.55, 10.08), 3, 1, {
		name="gudangkota",
		heading=49,
		--debugPoly=true,
		minZ=7.48,
		maxZ=11.48
    }, {
        options = {
            {
                event = "rd_gudang:gudangkota",
                icon = "fas fa-warehouse",
                label = "Buka Gudang",

            },
        },
		job = {"all"},
        distance = 1.5
    })

	exports.qtarget:AddBoxZone("gudangpaleto", vector3(147.41, 6366.67, 31.53 - 1), 1, 4.8, {
		name="gudangpaleto",
		heading=297,
		--debugPoly=true,
		minZ=30.53,
		maxZ=34.53
    }, {
        options = {
            {
                event = "rd_gudang:gudangpaleto",
                icon = "fas fa-warehouse",
                label = "Buka Gudang",

            },
        },
		job = {"all"},
        distance = 1.5
    })
end)



AEH('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
     print("\n^1----------------------------------------------------------------------------------^7")
     print("\n CREATED BY RD DEVELOPMENT TEAM")
     print("\n^1----------------------------------------------------------------------------------^7")
    end
 end)