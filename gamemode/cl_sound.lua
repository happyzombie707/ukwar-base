-- Not done yet, managing functions to properly manage a set number of audio channels playing on the clientside, for example, one bgm channel, and a SFX voiceover overlay channel
ACTIVE_SOUND_CACHE = {
	{},{},{}
}

INT_SOUND_TABLE = {
	GAME_STATE_BGM = 1,
	GAME_STATE_OVERLAY = 2,
	GAME_STATE_ANNOUNCER = 3,
}

CONST_STR_PEER_ADDRESS = "127.0.0.1"
STR_SOUND_TABLE = {
	{
		"s_in_a1_l.wav",
		"Two Steps From Hell - Archangel.mp3"
	},
	{
		"sfx or something"
	},
	{
		"snd_se_narration_five.wav", --announcer
		"snd_se_narration_four.wav",
		"snd_se_narration_three.wav",
		"snd_se_narration_two.wav",
		"snd_se_narration_one.wav",
		"snd_se_menu_Narration_BattleRoyal.wav",
		"snd_se_narration_Gameset.wav",
		"snd_se_narration_Go.wav"
	}
}

ANNOUNCER_LENGTH = 1
SND_CHAIN = {
	{
		l = 1,
		a = {
			{f = 1, p = 2,},
		}
	},
	{
		l = 1,
		a = {
			{f = 1, p = 2,},
		}
	},
	{
		{
			l = 7,
			a = {
				-- Countdown sequence
				{f = 1, p = 1,},
				{f = 2, p = 1,},
				{f = 3, p = 1,},
				{f = 4, p = 1,},
				{f = 5, p = 1,},
				{f = 6, p = 1,},
				--{f = 7, p = 2,},
				{f = 8, p = 1,},
			}
		}
	}
}
bFlagSequencerActive = false
TABLE_SEQUENCER_DATA = {
	{ bActive = false, intLastTick = 0, intDelay = 5, intSequence = 0, intPosition = 0, intNextSequence = 0 },	 -- GAME_STATE_BGM
	{ bActive = false, intLastTick = 0, intDelay = 60, intSequence = 0, intPosition = 0, intNextSequence = 0 },	 -- GAME_STATE_OVERLAY
	{ bActive = false, intLastTick = 0, intDelay = 0, intSequence = 0, intPosition = 0, intNextSequence = 0 }	 -- GAME_STATE_ANNOUNCER
}

function SND_Sequencer_Tick()
	for k, v in pairs(TABLE_SEQUENCER_DATA) do
		if(v.bActive == true) then
			if(v.intLastTick < (CurTime())) then
				--print("Key: ", k);
				--print("Tick: ", v.intLastTick +v.intDelay , " : ", CurTime())
				if( v.intSequence <= ANNOUNCER_LENGTH ) then
					--v.intNextSequence > -1) then
					--if(k == INT_SOUND_TABLE.GAME_STATE_ANNOUNCER) then
					--print(k)
					--PrintTable(SND_CHAIN[k]) 
					--[v.intSequence]
						--print("Position: ", v.intPosition, SND_CHAIN[k].l,  v.intDelay)
						if(v.intPosition <= SND_CHAIN[k][v.intSequence].l) then
							--[v.intSequence]
							SND_Play(k, SND_CHAIN[k][v.intSequence].a[v.intPosition].f)
							print("Loading: ", SND_CHAIN[k][v.intSequence].a[v.intPosition].f)
							v.intLastTick = CurTime() + SND_CHAIN[k][v.intSequence].a[v.intPosition].p + v.intDelay
							v.intPosition = v.intPosition + 1
							print("Updated to next sound")
						else
							v.bActive = false
							print("Stopped sequence")
						end
					--end
					-- + v.intDelay
					--print("Updated tick\n")
				end
				
				--if( ACTIVE_SOUND_CACHE[k]:IsPlaying() ) then
				--	printf("Playing")
				--end
				
			else 
				
			end
		end
	end
	--for k, v in pairs(TABLE_SEQUENCER_DATA) do
		--if(v.bActive) then

		--end
	--end
end

function SND_ChannelRunning(int_index) end
function SND_ExecuteSequence(In_int_TYPE, In_int_sequence)
	print("Executing sound sequence, ", In_int_TYPE)
	PrintTable(TABLE_SEQUENCER_DATA)
	TABLE_SEQUENCER_DATA[In_int_TYPE].intLastTick = CurTime()
	TABLE_SEQUENCER_DATA[In_int_TYPE].intPosition = 1
	TABLE_SEQUENCER_DATA[In_int_TYPE].intNext = -1 -- None
	TABLE_SEQUENCER_DATA[In_int_TYPE].intSequence = In_int_sequence

	SND_Play(In_int_TYPE, In_int_sequence)

	TABLE_SEQUENCER_DATA[In_int_TYPE].bActive = true
end

function SND_Play(Int_type, int_index)
	--local filter
	--filter = RecipientFilter()
	--filter:AddAllPlayers()

	print("Key: ", Int_type, int_index)
	--print("Table: ")
	--PrintTable(STR_SOUND_TABLE)


	sound.PlayURL ( "http://" .. CONST_STR_PEER_ADDRESS .. "/fastdl/sound/announcer/" .. STR_SOUND_TABLE[Int_type][int_index], "2d", --output.mp3", "3d", 
		function( station )
			if ( IsValid( station ) ) then
				--station:SetPos( LocalPlayer():GetPos() )
				station:Play()
			else
			LocalPlayer():ChatPrint( "Invalid sound address!" )
			end
		end)


	-- GAME_STATE_ANNOUNCER
	--if(soundList[int_index]:playing()
	-- =
	--SOUND =  CreateSound( game.GetWorld(), STR_SOUND_TABLE[Int_type][int_index], filter )
	
	
	--SOUND:Play()
	--if soundList[ind_index] then
	--	sound:SetSoundLevel( 0 ) -- play everywhere
		--if CLIENT then
			--LoadedSounds[FileName] = { sound, filter } -- cache the CSoundPatch
		--end
	--end
	--if soundList[int_index] then
	--	if CLIENT then
	--		soundList[int_index]:Stop() -- it won't play again otherwise
	--	end
	--	soundList[int_index]:ChangeVolume(0.1, 0)
	--	soundList[int_index]:Play()
	--	soundList[int_index]:ChangeVolume(1, 10)
	--end
end
-- The sound is always re-created serverside because of the RecipientFilter.
--sound = CreateSound( game.GetWorld(), FileName, filter ) -- create the new sound, parented to the worldspawn ( which always exists )
	