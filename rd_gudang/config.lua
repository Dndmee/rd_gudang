RD = {}

RD.HargaSewa = 100000 -- Biaya Sewa Gudang
RD.rentalTime = 1440 * (60 * 1000) --=== 24 hours

RNE = RegisterNetEvent
AEH = AddEventHandler
RSE = RegisterServerEvent


RD.LokasiGudang = {
    ['pantai'] = {
        coords = vec4(-1607.59, -830.55, 10.08, 142.7980), ---=== coords target
        targetDebug = false, ---=== debug zone target
        id = "gudang_pantai", ---=== id gudang tidak bisa menggunakan spasi/jarak
        label = "Gudang Pantai", ---=== label gudang dan label target
        stashWeight = 10000000, ---=== kapasitas gudang
    },
    ['plaeto'] = {
        coords = vec4(147.41, 6366.67, 31.53, 297),
        targetDebug = false,
        id = "gudang_plaeto",
        label = "Gudang Paleto",
        stashWeight = 10000000
    }
}