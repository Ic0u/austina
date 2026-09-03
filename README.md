# Austina

Roblox script loader with a cinematic initialization sequence and a callback-based module API.

## Default launch

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ic0u/austina/main/loader.lua"))().Start()
```

## Custom completion callback

```lua
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ic0u/austina/main/loader.lua"))()

Loader.Start(function()
    -- Launch the main Austina window here.
end)
```

When no callback is supplied, `Loader.Start()` loads the matching game script from `games.json`, or falls back to `scripts/Universal.lua`.
