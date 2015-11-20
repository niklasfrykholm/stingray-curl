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

function Http.get(url)
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
	print("CURL-RESULT: ", result)
	if result ~= curl.CURLE_OK then
		print("CURL-FAILURE:", ffi.string(curl.curl_easy_strerror(result)))
	else
		print("CURL-SUCCESS:", data)
	end
	curl.curl_easy_cleanup(ch)
end

Http.get("http://www.example.com")

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

-- Optional function called by SimpleProject after world update (we will probably want to split to pre/post appkit calls)
function Project.update(dt)
end

-- Optional function called by SimpleProject *before* appkit/world render
function Project.render()
end

-- Optional function called by SimpleProject *before* appkit/level/player/world shutdown
function Project.shutdown()
end

return Project
