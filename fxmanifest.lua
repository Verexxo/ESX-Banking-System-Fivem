fx_version 'cerulean'
game 'gta5'
description 'ESX banking'
lua54 'yes'
version '1.0'
legacyversion '1.9.1'
shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}
ui_page 'html/ui.html'
files {
	'html/**',
}
dependency 'es_extended'
client_script '@Kubus_loader/c_loader.lua'
server_script '@Kubus_loader/s_loader.lua'
my_data 'client_files' { 'client/main.lua' }