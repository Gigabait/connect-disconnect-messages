workspace "gmsv_iptocountry"
	language     "C++"
	architecture "x86"
	location     "build"
	targetdir    "lua/bin/"

	defines "GMMODULE"

	flags {
		-- Let's build this without any warnings!
		-- NOTE: This is impossible with Bootil included...
		"FatalCompileWarnings",
		"FatalLinkWarnings",
		"FatalWarnings",

		-- VS Multi-core compile.
		"MultiProcessorCompile",

		-- Static link to runtime libraries.
		"StaticRuntime",
		-- Whole-program optimization.
		"LinkTimeOptimization",
	}

	configurations "Release"

	configuration "Release"
		-- Full optimization.
		optimize "Full"

	project "gmsv_iptocountry"
		kind "SharedLib"

		include "src/LuaInterface"

		-- defines {
		-- 	"BOOTIL_COMPILE_STATIC",
		-- 	"BOOST_ALL_NO_LIB"
		-- }

		includedirs {
			"src/LuaInterface/src/",

			-- "src/Bootil/include/",
			-- "src/Bootil/src/3rdParty/",

			"src/ip2c/",
		}

		files {
			-- "src/**.c",
			-- "src/**.cc",
			-- "src/**.cpp",
			-- "src/**.hpp",
			-- "src/**.h",

			"src/LuaInterface/**.h",

			"src/ip2c/ip2c.cpp",
			"src/ip2c/ip2c.hpp",

			"src/main.cpp",
		}
