--[[
	Project: RoguelikeProto
	File: utils.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 8/3/2016
	
	Comments:
		Some basic functions to make working in lua a little simpler.
--]]

--[[
-- Simple string indexing without overriding string functions. For example:
--		local s = "abcde"
--		s[3] --> 'c'
--]]
getmetatable( '' ).__index = function( str, i )
	if (type( i ) == 'number')
	then
		return string.sub( str, i, i )
	else
		return string[i]
	end
end

--[[
-- Slightly more advanced string indexing capabilities. For example:
--		local s = "abcde"
--		s(3,5) --> "cde"
--		s{1,4,2} --> "adb"
--]]
getmetatable( '' ).__call = function( str, i, j )
	if (type(i) ~= 'table')
	then
		return string.sub( str, i, j )
	else
		local t = {}
		
		for k, v in ipairs(i)
		do
			t[k] = string.sub( str, v, v )
		end
		
		return table.concat( t )
	end
end


-- A simple helper method to clamp a value between a range
function math.clamp( x, min, max )
	if (x < min) then return min end
	if (x > max) then return max end
	return x
end

function math.sign( x )
	if x < 0
	then
		return -1
	elseif x > 0
	then
		return 1
	else
		return 0
	end
end

-- Implemented a custom contains function for tables
function table.contains( t, value )
	for idx, entry in pairs( t )
	do
		if entry == value
		then
			return true, idx
		end
	end
	
	return false
end

-- A specific contains function which only checks numeric indices
function table.icontains( t, value )
	for idx, entry in ipairs( t )
	do
		if (entry == value)
		then
			return true, idx
		end
	end
	
	return false
end

function table.val_to_str ( v, tabs )
	if "string" == type( v )
	then
		v = string.gsub( v, "\n", "\\n" )
		
		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' )
		then
			return "'" .. v .. "'"
		end
		
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type( v ) and table.tostring( v, (tabs or '') .. '\t' ) or
		tostring( v )
	end
end

function table.key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" )
	then
		return k
	else
		return "[" .. table.val_to_str( k ) .. "]"
	end
end

function table.tostring( tbl, tabs )
	tabs = tabs or ''

	local result, done = {}, {}
	for k, v in ipairs( tbl )
	do
		table.insert( result, table.val_to_str( v, tabs ) )
		done[ k ] = true
	end
	for k, v in pairs( tbl )
	do
		if not done[ k ]
		then
			table.insert( result, table.key_to_str( k ) .. "=" .. table.val_to_str( v, tabs ) )
		end
	end
	
	return "{\n" .. tabs .. '\t' .. table.concat( result, ",\n" .. tabs .. '\t' ) .. '\n' .. tabs .. '}'
end

--[[
-- Tests a bit flag.
--		local flags = 0x03
--		TestFlag( flags, 0x01 ) --> true
--		TestFlag( flags, 0x04 ) --> false
--]]
function TestFlag( set, flag )
	return set % (2 * flag) >= flag
end

--[[
-- Sets a bit flag
--		local flags = 0x01
--		flags = SetFlag( flags, 0x02 ) --> 0x03
--]]
function SetFlag( set, flag )
	if set % (2 * flag) >= flag
	then
		return set
	end
	
	return set + flag
end

--[[
-- Clears a bit flag
--		local flags = 0x03
--		flags = ClearFlag( flags, 0x02 ) --> 0x01
--]]
function ClearFlag( set, flag )
	if set % (2 * flag) >= flag
	then
		return set - flag
	end
	
	return set
end

-- Basic lerp function
function Lerp( a, b, t )
	return a + ((b - a) * t)
end