<div align="center">

<img src="./assets/vinershub.png" alt="Vinsers Hub logo" width="220">

<h3>Vinsers Hub</h3>

A lightweight Roblox script hub by Marcus.

![Lua](https://img.shields.io/badge/Language-Luau-2C2D72?style=flat-square&logo=lua&logoColor=white)
![Version](https://img.shields.io/badge/Version-v1.0.0-5A9CFF?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-5A9CFF?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-202124?style=flat-square)

</div>

## Loadstring

```lua
local a,b,c=loadstring,request or http_request or (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request),"https://raw.githubusercontent.com/Ic0u/austina/main/loader.lua";assert(a and b,"Executor not supported");local r=b({Url=c,Method="GET",Headers={["User-Agent"]="VinsersHub",["Cache-Control"]="no-cache"}});local s=type(r)=="table" and (r.Body or r.body) or r;assert(type(s)=="string" and s~="","Request failed");a(s)().Start()
```

## Supported Executors

`Volt` · `Potassium` · `Synapse Z` · `Wave` · `Opiumware` · `MacSploit` · `Delta X`

> The loader requires `loadstring` and an HTTP request function. ESP features also require the Drawing API.

## Supported Games

| Game | Place ID |
| --- | ---: |
| [Blox Fruits — First Sea](https://www.roblox.com/games/2753915549/) | `2753915549` |
| [Blox Fruits — Second Sea](https://www.roblox.com/games/4442272183/) | `4442272183` |
| [Blox Fruits — Third Sea](https://www.roblox.com/games/7449423635/) | `7449423635` |
| Universal fallback | Any other place |

<p align="center">
  <a href="https://discord.gg/r7E9j8h4w2">
    <img src="https://img.shields.io/badge/Join_Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Join Discord">
  </a>
</p>
