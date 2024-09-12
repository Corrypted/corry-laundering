description 'Made With Fivem-Script-Template by Amped'

fx_version 'cerulean'

games { 'rdr3', 'gta5' }

lua54 'yes'

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua'
}
