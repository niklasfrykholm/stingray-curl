-----------------------------------------------------------------------------------
-- This implementation uses the default SimpleProject and the Project extensions are
-- used to extend the SimpleProject behavior.

-- This is the global table name used by Appkit Basic project to extend behavior
Project = Project or {}

require 'script/lua/flow_callbacks'

Project.level_names = {
	empty = "content/levels/empty"
}

-- Load curl
local ffi = require 'ffi'
local curl = require 'script/lua/luajit-curl'

Http = Http or {}

Http.get = function(url)
	local ch = curl.curl_easy_init()
	curl.curl_easy_setopt(ch, curl.CURLOPT_URL, url)
	curl.curl_easy_setopt(ch, curl.CURLOPT_FOLLOWLOCATION, 1)

	local data = nil
	local cb = function(ptr, size, nmemb, stream)
		local bytes = size*nmemb
        local buf = ffi.new('char[?]', bytes+1)
        ffi.copy(buf, ptr, bytes)
        buf[bytes] = 0
        data = ffi.string(buf)
        return bytes
	end
	local fptr = ffi.cast("size_t (*)(char *, size_t, size_t, void *)", cb)
	curl.curl_easy_setopt(ch, curl.CURLOPT_WRITEFUNCTION, fptr)
	local result = curl.curl_easy_perform(ch)
	curl.curl_easy_cleanup(ch)
	if result ~= curl.CURLE_OK then
		return nil, ffi.string(curl.curl_easy_strerror(result))
	else
		return data
	end
end

SimpleGui = SimpleGui or {}

SimpleGui.font = 'core/performance_hud/debug'
SimpleGui.font_material = 'core/performance_hud/debug'
SimpleGui.font_size = 20

SimpleGui.init = function (world)
	local state = {}
	state.gui = stingray.World.create_screen_gui(world or stingray.Application.main_world(), "immediate")
	local w,h = stingray.Application.back_buffer_size()
	state.size = {width = w, height = h}
	state.x = 50
	state.y = 50
	return state
end

SimpleGui.draw = function (state, text)
	local pos = stingray.Vector2(state.x, state.size.height - state.y)
	stingray.Gui.text(state.gui, text, SimpleGui.font, SimpleGui.font_size, SimpleGui.font_material, pos, stingray.Color(255,255,255))
	state.y = state.y + 20
end

SimpleGui.button = function (state, text)
	state.button_index = state.button_index or 1
	SimpleGui.draw(state, "[" .. state.button_index .. "] " .. text)
	local b = stingray.Keyboard.button_index("" .. state.button_index)
	state.button_index = state.button_index + 1
	return stingray.Keyboard.pressed(b)
end

-- Can provide a config for the basic project, or it will use a default if not.
local SimpleProject = require 'core/appkit/lua/simple_project'
SimpleProject.config = {
	standalone_init_level_name = Project.level_names.empty,
	camera_unit = "core/appkit/units/camera/camera",
	camera_index = 1,
	shading_environment = nil, -- Will override levels that have env set in editor.
	create_free_cam_player = true, -- Project will provide its own player.
	exit_standalone_with_esc_key = true
}

-- Optional function by SimpleProject after level, world and player is loaded
-- but before lua trigger level loaded node is activated.
function Project.on_level_load_pre_flow()
end

-- Optional function by SimpleProject after loading of level, world and player and
-- triggering of the level loaded flow node.
function Project.on_level_shutdown_post_flow()
end

local gui_state = nil
local data = ""

-- Optional function called by SimpleProject after world update (we will probably want to split to pre/post appkit calls)
function Project.update(dt)
	-- Http.get("http://www.example.com")
	gui_state = gui_state or SimpleGui.init()
	local gs = gui_state
	gs.x, gs.y = 50, 50
	gs.button_index = 1
	if SimpleGui.button(gs, "GET http://www.example.com") then
		data = Http.get("http://www.example.com")
	end
	SimpleGui.draw(gs, "")
	for s in string.gmatch(data, ".-\r?\n") do
		SimpleGui.draw(gs, s)
	end
end

-- Optional function called by SimpleProject *before* appkit/world render
function Project.render()
end

-- Optional function called by SimpleProject *before* appkit/level/player/world shutdown
function Project.shutdown()
end

return Project
