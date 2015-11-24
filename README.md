# stingray-curl

This is a sample project showing how LuaJIT's FFI functionality can be used to extend Stingray.

LuaJIT's FFI functions can be used to load and call arbitrary DLLs. In this example we load `libcurl` and use it to fetch web content into Stingray.

## Installation instructions

* Copy the DLL files from the `bin/` folder to the directory of your Stingray executable (`engine/win64/dev`).
* Add the `curl-project` project to your Stingray projects and run it.