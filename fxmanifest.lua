fx_version 'cerulean'
game 'gta5'
description 'east_hud'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

client_script 'client/main.lua'

export 'seatbelt'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/app.js',
    'ui/*.css',
}

dependency 'ox_lib'
lua54 'yes'
use_experimental_fxv2_oal 'yes'