local base = "https://raw.githubusercontent.com/Nestor12-dev-glich/nstor/refs/heads/main/"
local parts = {"part1.lua", "part2.lua", "part3.lua", "part4.lua"}
for _, p in ipairs(parts) do
    loadstring(game:HttpGet(base .. p))()
end
