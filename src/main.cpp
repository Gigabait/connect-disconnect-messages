#include "GarrysMod/Lua/Interface.h"
//#include "Bootil/Bootil.h"
#include "ip2c/ip2c.hpp"
#include <vector>

using namespace GarrysMod;

int ip2c_CountryStringIntermediate(
	char const * const ip,
	unsigned len,
	char const ** out)
{
	//if (!ip2c.IsReady())
	//	return ip2c::ERROR::NOT_READY;

	*out = "test";
	return ip2c::ERROR::NONE;
}

char const * lua_CountryString(lua_State *state, int index)
{
	int error;
	unsigned len;
	char const * country = NULL;
	char const * const ip = LUA->GetString(index, &len);

	error = ip2c_CountryStringIntermediate(ip, len, &country);

	if (error == ip2c::ERROR::NONE)
		return country;

	if (error == ip2c::ERROR::NOT_READY)
		return NULL;

	LUA->ThrowError("invalid ip given!");

	return NULL;
}

int lua_CountryStringTable(lua_State *state)
{
	std::vector<char const *> countries;

	countries.reserve(16);

	for (int i = 1; ; ++i)
	{
		// stack_top = tbl[i]
		LUA->PushNumber(i);
		LUA->GetTable(1);

		// type(stack_top)
		int type = LUA->GetType(-1);

		if (type == Lua::Type::NIL)
		{
			// we've reached the end of the table (probably)
			break;
		}
		else if (type != Lua::Type::STRING)
		{
			LUA->ThrowError("value is not a string!");
			return 0;
		}

		// country = iptocountry(stack_top)
		char const * country = lua_CountryString(state, -1);

		if (country == NULL)
			return 0;

		countries.push_back(country);
	}

	if (countries.size() < 1)
	{
		LUA->ThrowError("empty table passed!");
		return 0;
	}

	// ret = {}
	LUA->CreateTable();

	int i = 1;

	for (auto country : countries)
	{
		// ret[i] = country
		LUA->PushNumber(i);
		LUA->PushString(country);
		LUA->SetTable(-3);

		++i;
	}

	return 1;
}

int Lua_ip2c(lua_State *state)
{
	if (LUA->Top() != 1)
	{
		LUA->ThrowError("pass an IPv4 string or a table of IPv4 strings!");
		return 0;
	}

	int itemsReturned = 0;
	int type = LUA->GetType(1);

	if (type == Lua::Type::STRING)
	{
		char const * country = lua_CountryString(state, 1);

		if (country != NULL)
		{
			// return country
			LUA->PushString(country);
			itemsReturned = 1;
		}
	}
	else if (type == Lua::Type::TABLE)
	{
		itemsReturned = lua_CountryStringTable(state);
	}
	else
	{
		LUA->ThrowError("argument is not a string and is not a table!");
	}

	return itemsReturned;
}

GMOD_MODULE_OPEN()
{
	// _G["ip2c"] = Lua_ip2c
	LUA->PushSpecial(Lua::SPECIAL_GLOB);
		LUA->PushString("ip2c");
		LUA->PushCFunction(Lua_ip2c);
	LUA->SetTable(-3);

	return 0;
}
