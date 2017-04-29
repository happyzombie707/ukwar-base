local listBots = {}

function DEBUG_CreateBot()
	if ( !game.SinglePlayer() && #player.GetAll() < game.MaxPlayers() ) then
		local num = #listBots
		listBots[ num ] = player.CreateNextBot( "Bot_" .. ( num + 1 ) )
		return listBots[ num ]
	else
		print( "Can't create bot!" )
	end
end