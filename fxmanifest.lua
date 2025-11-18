
fx_version 'bodacious'
games { 'gta5' }

author 'devexity'
description 'Carry script for fivem'
version '1.2.0'

shared_scripts {
    '@ox_lib/init.lua',
}


client_scripts { 
    "cl_carry.lua"
}
server_scripts {
    "sv_carry.lua",
    "devexity.lua"
}
