--require("iptocountry")

-- The message thing
util.AddNetworkString("connect_disconnect_message")

hook.Add("PlayerInitialSpawn", "cdmessage_connected", function(plr)
	-- net.Start("cdmessage_connected")
	-- net.WriteEntity(plr)
	-- net.Broadcast()
end)

gameevent.Listen("player_connect")
hook.Add("player_connect", "cdmessage_connecting", function(tbl)
	-- tbl.address - IP of the connected player.
	-- tbl.index
	-- tbl.bot - 1 or 0 if it is a bot or not.
	-- tbl.networkid - The SteamID the player has.
	-- tbl.name - Name of the connected player.
	-- tbl.userid - The UserID the player has.


end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "cdmessage_disconnected", function(tbl)
	-- tbl.reason - Reason for disconnecting.
	-- tbl.bot - 1 or 0 if it is a bot or not.
	-- tbl.networkid - The SteamID the player had.
	-- tbl.userid - The UserID the player had.
	-- tbl.name - The Name the player had.

	-- net.Start("cdmessage_disconnected")
	-- net.WriteString(tbl.networkid)
	-- net.WriteString(tbl.name)
	-- net.WriteString(tbl.reason)
	-- net.WriteBool(tobool(tbl.bot))
	-- net.Broadcast()
end)

function SendCDMessage(str)
	if str == "" then
		return
	end

	local compressed = util.Compress(str)
	local size = compressed:len()

	if size == 0 then
		return
	end

	net.Start("connect_disconnect_message")
	net.WriteUInt(size, 16)
	net.WriteData(compressed, size)
	net.Broadcast()
end
