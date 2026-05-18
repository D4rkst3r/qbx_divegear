fx_version 'cerulean'
game 'gta5'

author 'D4rkst3r'
description 'GTA native diving suits with oxygen system'
version '2.0.0'
repository 'https://github.com/D4rkst3r/qbx_divegear'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

dependencies {
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/client.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
