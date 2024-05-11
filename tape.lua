-- Declare Vars
local shell = require("shell")
local fs = require("filesystem")
local ts = require("tools/transfer")
local ocz = require, "ocz")

local lib = {}

-- Local Functions
local function fileToArray(filename)
  if fs.exists(filename) == false then
    handleError("file " .. filename .. " not found")
  end
  local file = io.open(filename, "r");
  local arr = {}
  for line in file:lines() do
    table.insert(arr, line);
  end
  file:close()
  return arr
end

-- Functions
function lib.makePkg(path, deps, name, ver, destdir)

  -- Check for errors
  if not fs.exists(path) then
    handleError(path .. " is an invalid path")
  elseif not fs.exists(destdir) then
    handleError(destdir .. " is an invalid path")
  elseif name == nil then
    handleError("name set failure")
  elseif ver == nil then
    handleError("version set failure")
  end

  local pkgdir = "/usr/pkg/pkgbuild/" .. name .. "-" .. ver
  local pkgtar = "/usr/pkg/pkgtars/" .. name .. ".tar"

  -- Generate Package Information
  fs.makeDirectory("/usr/pkg")
  fs.makeDirectory("/usr/pkg/pkgbuild")
  fs.makeDirectory("/usr/pkg/pkgtars")
  fs.makeDirectory(pkgdir)

  local infofile = io.open(pkgdir .. "/pkginfo", "w")
  local depsfile = io.open(pkgdir .. "/deps", "w")
  
  infofile:write(name .. "\n" .. ver)
  local i = #deps - 1
  while i > 0 do
    depsfile:write(deps[i] .. "\n")
    i = i - 1
  end
  
  infofile:close()
  depsfile:close()

  -- copy data from PATH to temp dir
  local cops =
  {
    cmd = "cp",
    i = false,
    f = false,
    n = false,
    r = true,
    u = false,
    P = false,
    v = false,
    x = false,
    skip = {},
  }

  local cargs = {}
  cargs[1] = path
  cargs[2] = pkgdir .. "/pkg"

  ts.batch(cargs, cops)

  -- create tar archive
  shell.setWorkingDirectory(pkgdir)
     shell.execute("tar -cf " .. pkgtar .. " " .. pkgdir .. "/")
  shell.setWorkingDirectory(destdir)

  -- compress tar archive
  ocz.compressFile(pkgtar, destdir .. "/" .. name .. ".tar.ocz")

  -- Remove temp data
  fs.remove(pkgdir)
  fs.remove(pkgtar)
  fs.remove("/usr/pkg/pkgbuild/" .. name .. "-" .. ver)
end

function lib.installPkg(path, destdir)
  print("wip")
end

return lib
