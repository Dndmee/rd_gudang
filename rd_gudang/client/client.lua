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

function LockerMenu(k, hasLocker, lockerName, kapasitas)
	local elements = {}
	
	if hasLocker then
		table.insert(elements, {
            header = 'Buka Gudang', 
            params = {
                event = "rd-openLocker",
                args = {
                    lokasi = k,
                    gudang = hasLocker,
                    namaGudang = lockerName,
                    kapasitas = kapasitas
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
        })
        exports['rd-menu']:openMenu(elements)
	end
	
	if not hasLocker then
		table.insert(elements, {
            header = 'Sewa Gudang',
            txt = 'Biaya Sewa Awal: $'.. ESX.Math.GroupDigits(RD.InitialRentPrice).."<br>Biaya Bulanan: $".. ESX.Math.GroupDigits(RD.DailyRentPrice),
            params = {
                event = "rd-sewaGudang",
                args = {
                    lokasi = k,
                    namaGudang = lockerName,
                }
            }
        })
        exports['rd-menu']:openMenu(elements)
    end

end

function Openstashopen(lockerId, identifier, lockerName, kapasitas)
    local owner = ESX.GetPlayerData().identifier
    ESX.TriggerServerCallback("rd_gudang:getPropertyInventory", function(inventory)
        if exports.ox_inventory:openInventory('stash', {id= lockerId, owner = owner}) == false then
            TriggerServerEvent('gudang:registerstash', {id = lockerId, nama = lockerName, kapasitas = kapasitas})
            exports.ox_inventory:openInventory('stash', {id = lockerId, owner = owner})
        end
		Wait(2000)
		LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
		TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
    end, identifier, lockerId)
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

RNE('rd_gudang:aksesGudang')
AEH('rd_gudang:aksesGudang', function (data)
	ESX.TriggerServerCallback('rd_gudang:checkLocker', function(checkLocker)
		LockerMenu(data.id, checkLocker, data.nama, data.kapasitas)
	end, data.id)
end)

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
    Openstashopen(data.lokasi, data.gudang, data.namaGudang, data.kapasitas)
end)

RNE("rd-berhentiSewaGudang", function(data)
    TriggerServerEvent('rd_gudang:stopRentingLocker', data.lokasi, data.namaGudang)
end)

Citizen.CreateThread(function()
    for k, v in pairs(RD.LokasiGudang) do 

        local gblip = AddBlipForCoord(vec3(v.coords.x, v.coords.y, v.coords.z))
        SetBlipSprite (gblip, 357)
        SetBlipColour (gblip, 41)
        SetBlipDisplay(gblip, 4)
        SetBlipScale  (gblip, 0.7)
        SetBlipAsShortRange(gblip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.label)
        EndTextCommandSetBlipName(gblip)

        exports.ox_target:addBoxZone({
            coords = vec3(v.coords.x, v.coords.y, v.coords.z),
            size = vec3(1, 1, 2),
            rotation = v.coords.w,
            debug = v.targetDebug,
            options = {
                {
                    name = v.id,
                    event = "rd_gudang:aksesGudang",
                    icon = 'fa-solid fa-warehouse',
                    label = "Akses "..v.label,
                    id = v.id,
                    nama = v.label,
                    kapasitas = v.stashWeight
                }
            }
        })
    end
end)

AEH('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
     print("\n^1----------------------------------------------------------------------------------^7")
     print("\n CREATED BY RD DEVELOPMENT TEAM")
     print("\n^1----------------------------------------------------------------------------------^7")
    end
 end)