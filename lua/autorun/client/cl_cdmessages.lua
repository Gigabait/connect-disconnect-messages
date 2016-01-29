local function utf8ToTable(str)
	local tbl = {}

	for p, c in utf8.codes(str) do
		table.insert(tbl, c)
	end

	return tbl
end

local function rgbStrToColor(str)
	local r = tonumber(str:sub(1, 2), 16)
	local g = tonumber(str:sub(3, 4), 16)
	local b = tonumber(str:sub(5, 6), 16)
	return Color(r, g, b)
end

-- If last table value is string then append this string to it.
local function tableInsertString(tbl, str)
	if #tbl == 0 then
		table.insert(tbl, str)
	else
		local v = tbl[#tbl]
		if isstring(v) then
			tbl[#tbl] = v .. str
		else
			table.insert(tbl, str)
		end
	end
end

-- If last table value is color-table then overwrite that shit.
local function tableInsertColor(tbl, clr)
	if #tbl == 0 then
		table.insert(tbl, clr)
	else
		local v = tbl[#tbl]
		if isstring(v) then
			tbl[#tbl] = clr
		else
			table.insert(tbl, clr)
		end
	end
end

-- Parse messages with colors into a table for chat.AddText().
-- EXAMPLES:
--   "foo ## bar" -> {"foo # bar"}
--   "and #ff0000cool" -> {"and ", Color(255, 0, 0), "cool"}
--   "no colors ##AABBCC" -> "no colors #AABBCC"
local function processColorMessage(msg)
	local chars = utf8ToTable(msg)
	local ret = {}
	local y = 1

	local i = 0
	while i <= #chars do
		i = i + 1

		-- char
		local c = utf8.char(chars[i])

		if c ~= "#" then
			continue
		end

		i = i + 1

		-- next char
		local nc = utf8.char(chars[i])
		assert(nc ~= "")

		-- handle '##'
		if nc == "#" then
			tableInsertString(ret, msg:sub(y, i))
			y = i + 1
			continue
		end

		local h = msg:sub(i, i + 5)

		-- Matches six hexadecimal digits.
		-- EXAMPLE: "abc123"
		assert(h:match("%x%x%x%x%x%x", 1) ~= nil)

		if not istable(ret[#ret]) then
			tableInsertString(ret, msg:sub(y, i - 2))

			table.insert(ret, rgbStrToColor(h))
		end

		i = i + 5
		y = i + 1
	end

	local v = msg:sub(y)
	if v ~= "" then
		tableInsertString(ret, v)
	end

	return ret
end

local function ProcessCDMessage()
	local msgLength = net.ReadUInt(16)

	if msgLength == 0 then
		return
	end

	local msg = util.Decompress(net.ReadData(msgLength))

	chat.Add(unpack(processColorMessage(msg)))
end

net.Receive("cdmessage_player_connected", ProcessCDMessage)
net.Receive("cdmessage_player_connecting", ProcessCDMessage)
net.Receive("cdmessage_player_disconnected", ProcessCDMessage)
