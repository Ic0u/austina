<div align="center">

# Austina

![Lua](https://img.shields.io/badge/Language-Lua-blue.svg?style=flat-square&logo=lua)
![Version](https://img.shields.io/badge/Version-v1.0.0-green.svg?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-brightgreen.svg?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-orange.svg?style=flat-square)

free roblox script hub developed by marcus.

---

### Gen Script

```lua
local a,b,c=loadstring,request or http_request or (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request),"https://raw.githubusercontent.com/Ic0u/austina/main/loader.lua";assert(a and b,"Executor not supported");local r=b({Url=c,Method="GET",Headers={["User-Agent"]="Austina",["Cache-Control"]="no-cache"}});local s=type(r)=="table" and (r.Body or r.body) or r;assert(type(s)=="string" and s~="","Request failed");a(s)().Start()
