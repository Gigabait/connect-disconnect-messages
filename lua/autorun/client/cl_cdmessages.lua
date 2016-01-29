local function utf8ToTable(str)
	local ret = {}

	for p, c in utf8.codes(str) do
		table.insert(ret, c)
	end

	return ret
end

-- sort of table.sub because it doesn't follow string.sub
--  exactly because I don't need it to
local function tableSubToUtf8(tbl, startPos, endPos)
	endPos = endPos or #tbl

	if (startPos > endPos) or (startPos < 1) or (endPos < 1) then
		return ""
	end

	local ret = ""

	for i = startPos, endPos do
		ret = ret .. utf8.char(tbl[i])
	end

	return ret
end

local function rgbStrToColor(str)
	local r = tonumber(str:sub(1, 2), 16)
	local g = tonumber(str:sub(3, 4), 16)
	local b = tonumber(str:sub(5, 6), 16)
	return Color(r, g, b)
end

-- If last table value is string then append this string to it.
local function tableInsertString(tbl, str)
	if str and str ~= "" then
		table.insert(tbl, str)
	end
end

-- If last table value is color-table then overwrite that shit.
local function tableInsertColor(tbl, clr)
	local v = tbl[#tbl]

	if istable(v) then
		tbl[#tbl] = clr
	else
		table.insert(tbl, clr)
	end
end

-- Parse messages with colors into a table for chat.AddText().
-- This obviously throws errors if you give an incorrect color in msg or
--  you don't use "##" in msg to represent a single "#".
-- EXAMPLES:
--   "foo ## bar" -> {"foo # bar"}
--   "and #ff0000cool" -> {"and ", Color(255, 0, 0), "cool"}
--   "no colors ##AABBCC" -> {"no colors #AABBCC"}
local function processColorMessage(msg)
	-- table of utf-8 character byte sequences
	-- i'll just call them char{s|acters}
	local chars = utf8ToTable(msg)
	-- the table return that's full of shit
	local ret = {}
	-- y is the start position of where we should sub from.
	-- an example being grabbing subbing a color from a string and then
	--  y would be the index of the character after the color:
	--  "foo #a1b2c3bar" -> y = 12 because 'b' is str[12]
	local y = 1

	-- i is just our current character index
	local i = 1
	while #chars >= i do
		local firstChar = utf8.char(chars[i])

		i = i + 1

		if firstChar ~= "#" then
			continue
		end

		local nextChar = utf8.char(chars[i])
		assert(nextChar ~= "")

		-- handle '##'
		if nextChar == "#" then
			-- example:
			--  from "foo##bar"
			--  insert "foo#" into ret
			--  set indexes to "bar"
			tableInsertString(ret, tableSubToUtf8(chars, y, i-1))
			i = i + 1
			y = i
			continue
		end

		local h = tableSubToUtf8(chars, i, i + 5)

		-- Matches six hexadecimal digits.
		-- EXAMPLE: "abc123"
		assert(h:match("%x%x%x%x%x%x", 1) ~= nil)

		-- insert the string before the color into ret
		tableInsertString(ret, tableSubToUtf8(chars, y, i - 2))

		-- insert the color table into ret
		tableInsertColor(ret, rgbStrToColor(h))

		i = i + 5
		y = i + 1
	end

	-- add in the rest of the string to ret
	local v = tableSubToUtf8(chars, y)
	if v and v ~= "" then
		tableInsertString(ret, v)
	end

	--PrintTable(ret)

	return ret
end

net.Receive("connect_disconnect_message", function()
	local msgLength = net.ReadUInt(16)

	if msgLength == 0 then
		return
	end

	local msg = util.Decompress(net.ReadData(msgLength))

	chat.AddText(unpack(processColorMessage(msg)))
end)
