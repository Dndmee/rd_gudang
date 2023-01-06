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

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

function LockerMenu(k, hasLocker, lockerName)
	local elements = {}
	
	if hasLocker then
		table.insert(elements, {label = 'Buka Locker', value = 'open_locker'})
		table.insert(elements, {label = 'Berhenti Rental Locker', value = 'stop_renting'})
	end
	
	if not hasLocker then
		table.insert(elements, {label = 'Sewa | Biaya Sewa Awal: <span style="color: green;">$' .. ESX.Math.GroupDigits(RD.InitialRentPrice) .. '</span> | Biaya Bulanan - <span style="color: green;">$' .. ESX.Math.GroupDigits(RD.DailyRentPrice) .. '</span>', value = 'start_locker'})
	end
	
	ESX.UI.Menu.CloseAll()
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'locker_menu', {
		title    = lockerName,
		align    = 'right',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'start_locker' then
			ConfirmLockerRent(k, lockerName)
			menu.close()
		elseif data.current.value == 'stop_renting' then
			StopLockerRent(k, lockerName)
			menu.close()
		elseif data.current.value == 'open_locker' then
			ESX.Streaming.RequestAnimDict('anim@heists@keycard@', function()
				TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
				TriggerServerEvent("InteractSound_SV:PlayOnSource", "stashopen", 0.6)
				Citizen.Wait(500)
				ClearPedTasksImmediately(playerPed)
			end)
			Openstashopen(k, playerIdent, lockerName)
			menu.close()
		end

	end, function(data, menu)
		menu.close()
	end)

end

function ConfirmLockerRent(k, lockerName)

    local elements = {
        {label = 'Yes', value = 'buy_yes'},
        {label = 'No', value = 'buy_no'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm_rent_locker', {
        title    = 'Apakah kamu ingin menyewa ' .. lockerName .. '',
        align    = 'right',
        elements = elements
    }, function(data, menu)

        if data.current.value == 'buy_yes' then
            menu.close()
			TriggerServerEvent('rd_gudang:startRentingLocker', k, lockerName)
        elseif data.current.value == 'buy_no' then
            menu.close()
        end

    end, function(data, menu)
        menu.close()
    end)  
end

function StopLockerRent(k, lockerName)

    local elements = {
        {label = 'Iya', value = 'buy_yes'},
        {label = 'Tidak', value = 'buy_no'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cancel_rent_locker', {
        title    = 'Apakah kamu ingin berhenti menyewa ' .. lockerName .. '',
        align    = 'right',
        elements = elements
    }, function(data, menu)

        if data.current.value == 'buy_yes' then
            menu.close()
			TriggerServerEvent('rd_gudang:stopRentingLocker', k, lockerName)
        elseif data.current.value == 'buy_no' then
            menu.close()
        end

    end, function(data, menu)
        menu.close()
    end)  
end

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

RegisterNetEvent('rd_gudang:gudangkota')
AddEventHandler('rd_gudang:gudangkota', function ()
	ESX.TriggerServerCallback('rd_gudang:checkLocker', function(checkLocker)
		LockerMenu('locker1', checkLocker, 'Gudang Kota')
	end, 'locker1')
end)

RegisterNetEvent('rd_gudang:gudangss')
AddEventHandler('rd_gudang:gudangss', function ()
	ESX.TriggerServerCallback('rd_gudang:checkLocker', function(checkLocker)
		LockerMenu('locker3', checkLocker, 'Gudang Sandy Shores')
	end, 'locker3')
end)

RegisterNetEvent('rd_gudang:gudangpaleto')
AddEventHandler('rd_gudang:gudangpaleto', function ()
	ESX.TriggerServerCallback('rd_gudang:checkLocker', function(checkLocker)
		LockerMenu('locker2', checkLocker, 'Gudang Paleto')
	end, 'locker2')
end)

--[[TARGET FUNCTION]]-- 
-- contoh function kalau pake ox_target

-- exports.ox_target:addSphereZone({
--     coords = vec3(x, y, z),
--     radius = 1,
--     debug = drawZones,
--     options = {
--         {
--             name = 'sphere',
--             event = 'NAMAEVENT',
--             icon = 'fa-solid fa-circle',
--             label = '(Debug) Sphere',
--             canInteract = function(entity, distance, coords, name) -- ini kalau ada fungsi tambahan
--                 return true
--             end
--         }
--     }
-- })

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



AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
     print("\n^1----------------------------------------------------------------------------------^7")
     print("\n CREATED BY RD DEVELOPMENT TEAM")
     print("\n^1----------------------------------------------------------------------------------^7")
    end
 end)