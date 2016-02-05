[unicode] string parsing in lua: not even once

------------

Lot's of stuff originally from
https://github.com/glua/module-base
and
https://github.com/glua/LuaInterface

------------


the server will be using a GMOD binary module to grab the player's country from
their IP


I don't like how some other addons that use GeoIP stuff send http requests
to websites so I'm just adding in a binary module to read from a local file which
the binary module will read from (the file can also be upgraded with the
update_data.py python3 file)


none of this is complete [yet]
