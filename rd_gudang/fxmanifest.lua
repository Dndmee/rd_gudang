fx_version 'Cerulean'
game {'gta5'}

author 'RD Project Development'
description 'Not For Sale by RD DEVELOPMENT'
version '1.0.0'

shared_scripts {
    'config*.lua',
}

client_scripts {
    'client/*.lua',
    '@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
}

server_scripts {
	'@async/async.lua', -- ini diganti sama folder Async mu yaa
	'@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}