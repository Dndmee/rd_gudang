ESX = nil

local Delay = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('rd_gudang:checkLocker', function(source, cb, lockerId)
	local rdid = source
	local xPlayer = ESX.GetPlayerFromId(rdid)
	MySQL.Async.fetchAll('SELECT * FROM rd_gudang WHERE lockerName = @lockerId AND identifier = @identifier', { ['@lockerId'] = lockerId, ['@identifier'] = xPlayer.identifier }, function(result) 
		if result[1] ~= nil then
			cb(true)
		else
			cb(false)
		end	
	end)
end)


RegisterServerEvent('rd_gudang:startRentingLocker')
AddEventHandler('rd_gudang:startRentingLocker', function(lockerId, lockerName) 
	local rdid = source
	local xPlayer = ESX.GetPlayerFromId(rdid)
			if xPlayer.getMoney() >= RD.InitialRentPrice then
				MySQL.Async.execute('INSERT INTO rd_gudang (identifier, lockerName) VALUES (@identifier, @lockerId)', {
					['@identifier'] = xPlayer.identifier,
					['@lockerId'] = lockerId
				})
				xPlayer.removeMoney(RD.InitialRentPrice)
				TriggerClientEvent('mythic_notify:client:SendAlert', rdid, { type = 'success', text = "Kamu mulai menyewa " ..lockerName.. ". Kamu akan dikenakan biaya Rp."..RD.DailyRentPrice.." harian (IDR)", length = 5000 })
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', rdid, { type = 'error', text = "Kamu tidak memiliki uang untuk membayar biaya penyewaan pertama.", length = 5000 })
			end
	end)


RegisterServerEvent('rd_gudang:stopRentingLocker')
AddEventHandler('rd_gudang:stopRentingLocker', function(lockerId, lockerName) 
	local rdid = source
	local xPlayer = ESX.GetPlayerFromId(rdid)
	MySQL.Async.fetchAll('SELECT * FROM rd_gudang WHERE lockerName = @lockerId AND identifier = @identifier', { ['@lockerId'] = lockerId, ['@identifier'] = xPlayer.identifier }, function(result)
		if result[1] ~= nil then
			MySQL.Async.execute('DELETE from rd_gudang WHERE lockerName = @lockerId AND identifier = @identifier', {
				['@lockerId'] = lockerId,
				['@identifier'] = xPlayer.identifier
			})
			TriggerClientEvent('mythic_notify:client:SendAlert', rdid, { type = 'inform', text = "Membatalkan penyewaan gudang.", length = 5000 })
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', rdid, { type = 'error', text = "Kamu tidak memiliki gudang ini.", length = 5000 })
		end
	end)
end)

function PayLockerRent(d, h, m)
	MySQL.Async.fetchAll('SELECT * FROM rd_gudang', {}, function(result)
		for i=1, #result, 1 do
			local xPlayer = ESX.GetPlayerFromIdentifier(result[i].identifier)
			if xPlayer then
				xPlayer.removeAccountMoney('bank', RD.DailyRentPrice)
				TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = "Kamu membayar Rp. "..RD.DailyRentPrice.." untuk biaya gudang.", length = 8000 })
			else
				MySQL.Sync.execute('UPDATE users SET bank = bank - @bank WHERE identifier = @identifier', { ['@bank'] = RD.DailyRentPrice, ['@identifier'] = result[i].identifier })
			end
		end
	end)
end

TriggerEvent('cron:runAt', 5, 10, PayLockerRent)

ESX.RegisterServerCallback('rd_gudang:getPropertyInventory', function(source, cb, owner, lockerName)
	local xPlayer    = ESX.GetPlayerFromIdentifier(owner)
	local blackMoney = 0
	local items      = {}
	local weapons    = {}

	cb({
		blackMoney = blackMoney,
		items      = items,
		weapons    = weapons,
		stash_name    = lockerName
	})
end)


RegisterServerEvent('gudang:registerstash', function(data)
	print(json.encode(data))
	exports.ox_inventory:RegisterStash(data.id, data.nama, 200, data.kapasitas, true)
end)

