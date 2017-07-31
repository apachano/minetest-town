--[[
TOWNS
Author: SonosFuer
This mod adds a protection system in the form of towns.
]]



--[===[
	Initialization
]===]


towns = {} -- Set up town arrays
towns.townlist = {}
towns.settings= {}
towns.settings.tset = true

--[==[
	Functions
]==]--

function towns.checkassistant(player)
	local townname = player:get_attribute("towns:town")
	if towns.townlist[townname].members[playername] == "assistant" or "mayor" then
		return true
	else
		return false
	end
end

function towns.checkmayor(player)
	local townname = player:get_attribute("towns:town")
	if towns.townlist[townname].members[playername] == "mayor" then
		return true
	else
		return false
	end
end

function towns.new(mayor, townname)
	local player = minetest.get_player_by_name(mayor)
	if towns.townlist[townname] == nil then
		towns.townlist[townname] = {}
		towns.townlist[townname].mayor = mayor
		towns.townlist[townname].members = {}
		towns.townlist[townname].members[mayor] = "mayor"
		towns.townlist[townname].description = "New Town!!!"
		minetest.chat_send_player(mayor, "You are now the mayor of " .. townname)
		player:set_attribute("towns:town", townname)
	else
		minetest.chat_send_player(mayor, "You need to leave your old town before making a new one")
		return false
	end
end

function towns.invite(player, townname)
	local playername = player:get_player_name()
	if townname then
		towns.townlist[townname].members[playername] = "invited"
	else
		return false
	end
end

function towns.join(player, townname)
	if player:get_attribute("towns:town") == nil then
		if towns.townlist[townname] ~= nil then
			if towns.townlist[townname].members[player] == "invited" then
				player:set_attribute("towns:town", townname)
				return true
			else
				minetest.chat_send_player(player, "You must be invited before joining a town")
				return false
			end
		else
			minetest.chat_send_player(player, "That town does not exist")
			return false
		end
	else
		minetest.chat_send_player(player, "You can't join a new town, use /town leave to leave your current town first.")
		return false
	end
end

function towns.leave(playername)
	local player = minetest.get_player_by_name(playername)
	local townname = player:get_attribute("town:town")
	if townname then
		towns.townlist[townname].members[playername] = nil
		player:set_attribute("town:town", nil)
		return true
	else
		return false
	end
end

function towns.delete(playername)

end

function towns.promote(player)
	local townname = player:get_attribute("town:town")
	local playername = player:get_player_name()
	if townname then
		if towns.townlist[townname].members[playername] == "citizen" then
			towns.townlist[townname].members[playername] = "assistant"
			return true
		else
			return false
		end
	else
		return false
	end
end

function towns.demote(player)
	local townname = player:get_attribute("towns:town")
	local playername = player:get_player_name()
	if townname then
		if towns.townlist[townname].members[playername] == "assistant" then
			towns.townlist[townname].members[playername] = "citizen"
			return true
		else
			return false
		end
	else
		return false
	end
end

function towns.transferowner(from, to)
	local townname = from:get_attribute("towns:town")
	if towns.townlist[townname].members[from] == "mayor" and town.townlist[townname].members[to] == "citizen" or "assistant" then
		towns.townlist[townname].members[to] = "mayor"
		towns.townlist[townname].members[from] = "assistant"
		towns.townlist[townname].mayor = to
		return true
	else
		return false
	end
end

function towns.sethome(player)
	local townname = player:get_attribute("towns:town")
	if towns.townlist[townname] then
		towns.townlist[townname].home = player:getpos()
		return true
	else
		return false
	end
end

function towns.home(player)
	local townname = player:get_attribute("towns:town")
	if towns.townlist[townname].home then
		player:setpos(towns.townlist[townname].home)
		return true
	else
		return false
	end
end

function towns.claim(player)
	local townname = player:get_attribute("towns:town")
	if towns.townlist[townname] then
	
	end
end

function towns.info(playername)
	local player = minetest.get_player_by_name(playername)
	local townname = player:get_attribute("towns:town")
	if townname then
		if towns.townlist[townname] then
			minetest.chat_send_player(playername, "==========================================================")
			minetest.chat_send_player(playername, "Info for: " .. townname)
			minetest.chat_send_player(playername, "Mayor: " .. towns.townlist[townname].mayor)
			minetest.chat_send_player(playername, towns.townlist[townname].description)
			minetest.chat_send_player(playername, "==========================================================")
		end
	else
		minetest.chat_send_player(playername, "You are not in a town")
	end
end

function towns.help(name)
	minetest.chat_send_player(name, "======================Towns===============================")
	minetest.chat_send_player(name, "/town new <townname>         -> Creates a new town")
	minetest.chat_send_player(name, "/town invite <playername>    -> Invites a player to your town")
	minetest.chat_send_player(name, "/town join <townname>        -> Joins a town (must be invited")
	minetest.chat_send_player(name, "/town leave                  -> Leaves current town")
	minetest.chat_send_player(name, "/town promote <player>       -> Promotes player to assistant")
	minetest.chat_send_player(name, "/town demote <player>        -> Demotes player to citizen")
	minetest.chat_send_player(name, "/town transferowner <player> -> Transfers towns ownership to specified player")
	minetest.chat_send_player(name, "/town sethome                -> Sets town home to current position")
	minetest.chat_send_player(name, "/town home                   -> Teleports you to your town home")
	minetest.chat_send_player(name, "/town claim                  -> Claims current block in towns name")
	minetest.chat_send_player(name, "/town unclaim                -> Removes current block from town claims")
	minetest.chat_send_player(name, "/town help                   -> Prints command list")
	minetest.chat_send_player(name, "/town here                   -> Displays town info for current position")
	minetest.chat_send_player(name, "/town info                   -> Displays town info for your town")
end

--[===[
	Chat commands
]===]
--[[
ChatCmdBuilder.new("town", function(cmd)
	cmd:sub("new :townname", function(name, townname)
		towns.new(name, townname)
	end)
	cmd:sub("invite :playername", function(name, player)
		if towns.checkassistant(name) then
			towns.invite(get_player_by_name(name), command2)
			return true
		else
			minetest.chat_send_player(name, "You must be atleast an assistant to do that")
			return false
		end
	end)
	)
end, {
	description = "Town commands",
	privs = {}
})
]]

function towns.commands(name, param)
	local args = param:split(" ")

	if args[1] == "help" then
		towns.help(name)
		return
	elseif args[1] == "info" then
		towns.info(name)
		return
	elseif args[1] == "new" then
		towns.new(name, args[2])
		return
	elseif args[1] == "invite" then
		if towns.checkassistant(name) then
			towns.invite(get_player_by_name(name), args[2])
			return true
		else
			minetest.chat_send_player(name, "You must be atleast an assistant to do that")
			return false
		end
	elseif args[1] == "join" then
		towns.join(get_player_by_name(name), args[2])
		return
	elseif args[1] == "leave" then
		towns.leave(name)
		return
	else
		towns.help(name)
	end
end

minetest.register_chatcommand("town", {
	description = "Towns command interface, type /town help",
	privs = {interact = true},
	func = function(name, param)
		towns.commands(name, param)
	end
})

minetest.register_chatcommand("towns", {
	description = "Towns command interface, type /town help",
	privs = {interact = true},
	func = function(name, param)
		towns.commands(name, param)
	end
})

if towns.settings.tset then
	minetest.register_chatcommand("t", {		description = "Towns command interface, type /t help",
		privs = {interact = true},
		func = function(name, param)
			towns.commands(name, param)
		end
	})
end


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
			towns.townlist = minetest.deserialize(string)
			
			minetest.debug("[towns] towns.mt successfully read.")
		else
			minetest.debug("[towns] String nill, read failed")
		end
	end
end

--Save towns database to file

function towns.save_to_file()
	local save = towns.townlist
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