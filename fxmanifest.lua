fx_version 'cerulean'
games { 'gta5' }

name 'Pulsar Animations'
description 'Emotes, shared/synced animations, ped props, and PTFX sync'
author 'Artmines - maintained for Pulsar Framework'
url 'https://pulsarframe.work'
version 'v1.0.0'

client_script '@pulsar_core/components/cl_error.lua'
shared_script '@pulsar_core/core/sh_pulsar.lua'
client_script '@pulsar_pwnzor/client/check.lua'

client_scripts({
	'shared/**/*.lua',
	'config/*.lua',
	'client/utils.lua',
	'client/main.lua',
	'client/menu.lua',
	'client/bindings.lua',
	'client/emotes.lua',
	'client/ptfxsync.lua',
	'client/pedfeatures.lua',
	'client/sharedemotes.lua',
	'client/pointing.lua',
	'client/items.lua',
	'client/chairs.lua',
	'client/selfie.lua',
})

server_scripts({
	'shared/**/*.lua',
	'config/*.lua',
	'server/*.lua',
})

lua54 'yes'