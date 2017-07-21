--[[
TOWNS
Author: SonosFuer
This mod adds a protection system in the form of towns.
]]



--[===[
	Initialization
]===]

--Add Chat Command Builder By rubenwardy
dofile(minetest.get_modpath("money") .. "/ChatCmdBuilder.lua")

towns = {} -- Set up town arrays
towns.data = {}
towns.data.townlist = {}
towns.settings= {}
towns.data.player = {}

--[==[
	Functions
]==]--

ChatCmdBuilder.new("town",
	function(cmd)
		cmd:sub("new :townname",
			function(name, townname)
				if towns.data.townlist[townname] ~= nil then
					return false, "Town with the name " .. townname .. " already exists. Try another name."
				end
				if towns.data.player[name].town ~= nil then
					return false, "You are already in " .. towns.data.player[name].town .. ". You must leave with /town leave " .. towns.data.player[name].town .. " before you can create a new town"
				end
				towns.data.townlist[townname] = {}
				towns.data.townlist[townname].member = {}
				towns.data.townlist[townname].mayor = name
				towns.data.player[name].town = townname
				minetest.chat_send_player(name, "You are now the mayor of " .. townname)
			end
		)
	end,{
		description = "Commands for towns",
		privs = {
			basic_privs
		}
	}
)

ChatCmdBuilder.new("town",
	function(cmd)
		cmd:sub("leave",
			function(name)
				local town = towns.data.player[name].town
				minetest.chat_send_player(name, "you have left " .. town)
				towns.data.player[name].town = nil
				towns.data.townlist[town].member[name] = nil
			end
		)

		cmd:sub("invite :player",
			function(name, player)
				local town = towns.data.player[name].town
				minetest.chat_send_player(playername, name .. " has invited you to join " .. town " .. respond with /town join " .. town)
				town.invite = player
			end
		)

		cmd:sub("join :town",
			function(name, town)
				if(townlist[town].invite == name) then
					towns.data.townlist[town].member[name] = {}
					towns.data.townlist[town].member[name].rank = citizen
					towns.data.player[name].town = town
				end
			end
		)
	end,{
		description = "Commands for towns",
		privs = {
			basic_privs
		}
	}
)

--[[
suplimentary commands
]]--



--[===[
	File handling, loading data, saving data, setting up stuff for players.
]===]

-- Load the towns database from a previous session, if available.
do
	local filepath = minetest.get_worldpath().."/towns.mt"
	local file = io.open(filepath, "r")
	if file then
		minetest.log("action", "[towns] towns.mt opened.")
		local string = file:read()
		io.close(file)
		if(string ~= nil) then
			towns.data = minetest.deserialize(string)
			
			minetest.debug("[towns] towns.mt successfully read.")
		else
			minetest.debug("[towns] String nill, read failed")
		end
	end
end

--Save towns database to file

function towns.save_to_file()
	local save = towns.data
	local savestring = minetest.serialize(save)

	local filepath = minetest.get_worldpath().."/towns.mt"
	local file = io.open(filepath, "w")
	if file then
		file:write(savestring)
		io.close(file)
		minetest.log("action", "[towns] Wrote towns data into "..filepath..".")
	else
		minetest.log("error", "[towns] Failed to write towns data into "..filepath..".")
	end
end

--Catch the server while it shuts down

minetest.register_on_shutdown(
	function()
		minetest.log("action", "[towns] Server shuts down. Rescuing data into towns.mt")
		towns.save_to_file()
	end
)

--Add a new player to the database if they are not already there

minetest.register_on_joinplayer(
	function(player)
		local playername = player:get_player_name()
		
		if towns.data.player[playername] == nil then
			towns.data.player[playername] = {}
		end
	end
)