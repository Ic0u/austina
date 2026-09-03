-- Austina Blox Fruits compatibility port.
-- The attached script is treated as source material only. Its custom UI,
-- promotional clipboard action, and third-party remote loader are excluded.

local BASE_URL = "https://raw.githubusercontent.com/Ic0u/austina/main/"
local SUPPORTED_PLACES = {
    [2753915549] = true,
    [4442272183] = true,
    [7449423635] = true,
}

if not SUPPORTED_PLACES[game.PlaceId] then
    warn("Austina Blox Fruits module was loaded in an unsupported place")
    return
end

local environment = (getgenv and getgenv()) or _G
if environment.AustinaBloxFruitsLoaded then
    warn("Austina Blox Fruits is already running")
    return
end
environment.AustinaBloxFruitsLoaded = true

local function loadRemoteModule(path)
    local fetched, source = pcall(game.HttpGet, game, BASE_URL .. path)
    if not fetched or type(source) ~= "string" or source == "" then
        error("Austina could not download " .. path)
    end

    local chunk, compileError = loadstring(source)
    if not chunk then
        error("Austina could not compile " .. path .. ": " .. tostring(compileError))
    end

    local ok, result = pcall(chunk)
    if not ok then
        error("Austina could not initialize " .. path .. ": " .. tostring(result))
    end

    return result
end

local UILibrary = loadRemoteModule("libraries/UILibrary.lua")
local UIAdapter = loadRemoteModule("libraries/BloxFruitsUIAdapter.lua")

UILibrary.SetConfigFolder("Austina/BloxFruits")

local AccentSoft = Color3.fromRGB(118, 194, 146)
local AccentDeep = Color3.fromRGB(56, 138, 92)

for _, key in ipairs({
    "Title Text Color", "Page Selected Color", "Section Text Color",
    "Label Color", "Dropdown Selected Color", "Search Icon Highlight Color",
}) do
    environment.UIColor[key] = AccentSoft
end

for _, key in ipairs({
    "Section Underline Color", "Toggle Border Color", "Toggle Checked Color",
    "Button Color", "Textbox Highlight Color", "Box Highlight Color",
    "Slider Highlight Color",
}) do
    environment.UIColor[key] = AccentDeep
end

environment.Team = environment.Team or "Pirates"
_G.FastAttack = true
_G.FastAttackDistance = 100

local function initializeFastAttack()
    if environment.rz_FastAttack then
        return
    end

    local player = game:GetService("Players").LocalPlayer
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local modules = replicatedStorage:WaitForChild("Modules", 10)
    local net = modules and modules:FindFirstChild("Net")
    local registerAttack = net and net:FindFirstChild("RE/RegisterAttack")
    local registerHit = net and net:FindFirstChild("RE/RegisterHit")
    local enemies = workspace:WaitForChild("Enemies", 10)
    local characters = workspace:WaitForChild("Characters", 10)

    if not player or not registerAttack or not registerHit or not enemies or not characters then
        warn("Austina fast attack is unavailable in this game build")
        return
    end

    local fastAttack = {}

    local function isAlive(character)
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        return humanoid and humanoid.Health > 0
    end

    local function collectTargets(folder, targets)
        local primary
        for _, model in ipairs(folder:GetChildren()) do
            local head = model:FindFirstChild("Head")
            if model ~= player.Character and head and isAlive(model)
                and player:DistanceFromCharacter(head.Position) <= _G.FastAttackDistance then
                table.insert(targets, { model, head })
                primary = primary or head
            end
        end
        return primary
    end

    function fastAttack:AttackNearest()
        local character = player.Character
        local equippedWeapon = character and character:FindFirstChildOfClass("Tool")
        if not equippedWeapon or not isAlive(character) then
            return
        end

        local targets = {}
        local primary = collectTargets(enemies, targets)
        primary = collectTargets(characters, targets) or primary
        if not primary or #targets == 0 then
            return
        end

        local leftClickRemote = equippedWeapon:FindFirstChild("LeftClickRemote")
        if leftClickRemote then
            for _, target in ipairs(targets) do
                local root = target[1]:FindFirstChild("HumanoidRootPart")
                if root then
                    local direction = (root.Position - character:GetPivot().Position).Unit
                    pcall(leftClickRemote.FireServer, leftClickRemote, direction, 1)
                end
            end
        elseif equippedWeapon.ToolTip ~= "Gun" then
            pcall(registerAttack.FireServer, registerAttack, 0)
            pcall(registerHit.FireServer, registerHit, primary, targets)
        end
    end

    environment.rz_FastAttack = fastAttack
    task.spawn(function()
        while environment.AustinaBloxFruitsLoaded do
            if _G.FastAttack then
                fastAttack:AttackNearest()
            end
            task.wait(0.05)
        end
    end)
end

task.spawn(initializeFastAttack)

if game.PlaceId == 2753915549 then
        World1 = true
    elseif game.PlaceId == 4442272183 then
        World2 = true
    elseif game.PlaceId == 7449423635 then
        World3 = true
    end

         function MaterialMon()
         if _G.SelectMaterial == "Radiactive Material" then
               MMon = "Factory Staff"
	            MPos = CFrame.new(-105.889565, 72.8076935, -670.247986, -0.965929747, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, -0.965929747)
				SP = "Bar"
			elseif _G.SelectMaterial == "Leather + Scrap Metal" then
			if game.PlaceId == 2753915549 then
				MMon = "Pirate"
				MPos = CFrame.new(-967.433105, 13.5999937, 4034.24707, -0.258864403, 0, -0.965913713, 0, 1, 0, 0.965913713, 0, -0.258864403)
				SP = "Pirate"
				MMon = "Brute"
				MPos = CFrame.new(-1191.41235, 15.5999985, 4235.50928, 0.629286051, -0, -0.777173758, 0, 1, -0, 0.777173758, 0, 0.629286051)
				SP = "Pirate"
				elseif game.PlaceId == 4442272183 then
		    		MMon = "Mercenary"
					MPos = CFrame.new(-986.774475, 72.8755951, 1088.44653, -0.656062722, 0, 0.754706323, 0, 1, 0, -0.754706323, 0, -0.656062722)
					SP = "DressTown"
				elseif game.PlaceId == 7449423635 then
			    	MMon = "Pirate Millionaire"
		  			MPos = CFrame.new(-118.809372, 55.4874573, 5649.17041, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
					SP = "Default"
				end
			elseif _G.SelectMaterial == "Magma Ore" then
    			if game.PlaceId == 2753915549 then
					MMon = "Military Soldier"
					MPos = CFrame.new(-5565.60156, 9.10001755, 8327.56934, -0.838688731, 0, -0.544611216, 0, 1, 0, 0.544611216, 0, -0.838688731)
					SP = "Magma"
					MMon = "Military Spy"
					MPos = CFrame.new(-5806.70068, 78.5000458, 8904.46973, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247)
					SP = "Magma"
				elseif game.PlaceId == 4442272183 then
    				MMon = "Lava Pirate"
					MPos = CFrame.new(-5158.77051, 14.4791956, -4654.2627, -0.848060489, 0, -0.529899538, 0, 1, 0, 0.529899538, 0, -0.848060489)
					SP = "CircleIslandFire"
				end
				elseif _G.SelectMaterial == "Fish Tail" then
				if game.PlaceId == 2753915549 then
					MMon = "Fishman Warrior"
					MPos = CFrame.new(60943.9023, 17.9492188, 1744.11133, 0.826706648, -0, -0.562633216, 0, 1, -0, 0.562633216, 0, 0.826706648)
					SP = "Underwater City"
					MMon = "Fishman Commando"
					MPos = CFrame.new(61760.8984, 18.0800781, 1460.11133, -0.632549644, 0, -0.774520278, 0, 1, 0, 0.774520278, 0, -0.632549644)
					SP = "Underwater City"
				elseif game.PlaceId == 7449423635 then
		    		MMon = "Fishman Captain"
	    			MPos = CFrame.new(-10828.1064, 331.825989, -9049.14648, -0.0912091732, 0, 0.995831788, 0, 1, 0, -0.995831788, 0, -0.0912091732)
			    	SP = "PineappleTown"
	     		end
				elseif _G.SelectMaterial == "Angel Wings" then
					MMon = "Royal Soldier"
					MPos = CFrame.new(-7759.45898, 5606.93652, -1862.70276, -0.866007447, 0, -0.500031412, 0, 1, 0, 0.500031412, 0, -0.866007447)
					SP = "SkyArea2"
					elseif _G.SelectMaterial == "Mystic Droplet" then
	    			MMon = "Water Fighter"
	    			MPos = CFrame.new(-3331.70459, 239.138336, -10553.3564, -0.29242146, 0, 0.95628953, 0, 1, 0, -0.95628953, 0, -0.29242146)
				    SP = "ForgottenIsland"
				   elseif _G.SelectMaterial == "Vampire Fang" then
			    	MMon = "Vampire"
				    MPos = CFrame.new(-6132.39453, 9.00769424, -1466.16919, -0.927179813, 0, -0.374617696, 0, 1, 0, 0.374617696, 0, -0.927179813)
			    	SP = "Graveyard"
			   elseif _G.SelectMaterial == "Gunpowder" then
		    		MMon = "Pistol Billionaire"
		    		MPos = CFrame.new(-185.693283, 84.7088699, 6103.62744, 0.90629667, -0, -0.422642082, 0, 1, -0, 0.422642082, 0, 0.90629667)
		   		    SP = "Mansion"
		       elseif _G.SelectMaterial == "Mini Tusk" then
			    	MMon = "Mythological Pirate"
			    	MPos = CFrame.new(-13456.0498, 469.433228, -7039.96436, 0, 0, 1, 0, 1, -0, -1, 0, 0)
			    	SP = "BigMansion"
		    	 elseif _G.SelectMaterial == "Conjured Cocoa" then
			    	MMon = "Chocolate Bar Battler"
				    MPos = CFrame.new(582.828674, 25.5824986, -12550.7041, -0.766061664, 0, -0.642767608, 0, 1, 0, 0.642767608, 0, -0.766061664)
				SP = "Chocolate"
				end
			end
     function CheckQuest()
        MyLevel = game:GetService("Players").LocalPlayer.Data.Level.Value
        if World1 then
            if (MyLevel >= 1 and MyLevel <= 9) or SelectMonster == "Bandit" then
                Mon = "Bandit"
                LevelQuest = 1
                NameQuest = "BanditQuest1"
                NameMon = "Bandit"
                CFrameQuest = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, -0, -0.341998369, 0, 1, -0, 0.341998369, 0, 0.939700544)
                CFrameMon = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
            elseif (MyLevel >= 10 and MyLevel <= 14) or SelectMonster == "Monkey" then
                Mon = "Monkey"
                LevelQuest = 1
                NameQuest = "JungleQuest"
                NameMon = "Monkey"
                CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0)
                CFrameMon = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)
            elseif (MyLevel >= 15 and MyLevel <= 29) or SelectMonster == "Gorilla" then
                Mon = "Gorilla"
                LevelQuest = 2
                NameQuest = "JungleQuest"
                NameMon = "Gorilla"
                CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0)
                CFrameMon = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875)
            elseif (MyLevel >= 30 and MyLevel <= 39) or SelectMonster == "Pirate" then
                Mon = "Pirate"
                LevelQuest = 1
                NameQuest = "BuggyQuest1"
                NameMon = "Pirate"
                CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
                CFrameMon = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125)
            elseif (MyLevel >= 40 and MyLevel <= 59) or SelectMonster == "Brute" then
                Mon = "Brute"
                LevelQuest = 2
                NameQuest = "BuggyQuest1"
                NameMon = "Brute"
                CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
                CFrameMon = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875)
            elseif (MyLevel >= 60 and MyLevel <= 74) or SelectMonster == "Desert Bandit" then
                Mon = "Desert Bandit"
                LevelQuest = 1
                NameQuest = "DesertQuest"
                NameMon = "Desert Bandit"
                CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
                CFrameMon = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)
            elseif (MyLevel >= 75 and MyLevel <= 89) or SelectMonster == "Desert Officer" then
                Mon = "Desert Officer"
                LevelQuest = 2
                NameQuest = "DesertQuest"
                NameMon = "Desert Officer"
                CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
                CFrameMon = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)
            elseif (MyLevel >= 90 and MyLevel <= 99) or SelectMonster == "Snow Bandit" then
                Mon = "Snow Bandit"
                LevelQuest = 1
                NameQuest = "SnowQuest"
                NameMon = "Snow Bandit"
                CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
                CFrameMon = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125)

            elseif (MyLevel >= 100 and MyLevel <= 119) or SelectMonster == "Snowman" then
                Mon = "Snowman"
                LevelQuest = 2
                NameQuest = "SnowQuest"
                NameMon = "Snowman"
                CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
                CFrameMon = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625)
            elseif (MyLevel >= 120 and MyLevel <= 149) or SelectMonster == "Chief Petty Officer" then
                Mon = "Chief Petty Officer"
                LevelQuest = 1
                NameQuest = "MarineQuest2"
                NameMon = "Chief Petty Officer"
                CFrameQuest = CFrame.new(-5039.58643, 27.3500385, 4324.68018, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                CFrameMon = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625)
            elseif (MyLevel >= 150 and MyLevel <= 174) or SelectMonster == "Sky Bandit" then
                Mon = "Sky Bandit"
                LevelQuest = 1
                NameQuest = "SkyQuest"
                NameMon = "Sky Bandit"
                CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
                CFrameMon = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625)

            elseif (MyLevel >= 175 and MyLevel <= 189) or SelectMonster == "Dark Master" then
                Mon = "Dark Master"
                LevelQuest = 2
                NameQuest = "SkyQuest"
                NameMon = "Dark Master"
                CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
                CFrameMon = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625)
            elseif (MyLevel >= 190 and MyLevel <= 209) or SelectMonster == "Prisoner" then
                Mon = "Prisoner"
                LevelQuest = 1
                NameQuest = "PrisonerQuest"
                NameMon = "Prisoner"
                CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712)
                CFrameMon = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781)
            elseif (MyLevel >= 210 and MyLevel <= 249) or SelectMonster == "Dangerous Prisone" then
                Mon = "Dangerous Prisoner"
                LevelQuest = 2
                NameQuest = "PrisonerQuest"
                NameMon = "Dangerous Prisoner"
                CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712)
                CFrameMon = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375)
            elseif (MyLevel >= 250 and MyLevel <= 274) or SelectMonster == "Toga Warrior" then
                Mon = "Toga Warrior"
                LevelQuest = 1
                NameQuest = "ColosseumQuest"
                NameMon = "Toga Warrior"
                CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298)
                CFrameMon = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625)
            elseif (MyLevel >= 275 and MyLevel <= 299) or SelectMonster == "Gladiator" then
                Mon = "Gladiator"
                LevelQuest = 2
                NameQuest = "ColosseumQuest"
                NameMon = "Gladiator"
                CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298)
                CFrameMon = CFrame.new(-1292.838134765625, 56.380882263183594, -3339.031494140625)
            elseif (MyLevel >= 300 and MyLevel <= 324) or SelectMonster == "Military Soldier" then
                Mon = "Military Soldier"
                LevelQuest = 1
                NameQuest = "MagmaQuest"
                NameMon = "Military Soldier"
                CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
                CFrameMon = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875)
            elseif (MyLevel >= 325 and MyLevel <= 374) or SelectMonster == "Military Spy" then
                Mon = "Military Spy"
                LevelQuest = 2
                NameQuest = "MagmaQuest"
                NameMon = "Military Spy"
                CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
                CFrameMon = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375)
            elseif (MyLevel >= 375 and MyLevel <= 399) or SelectMonster == "Fishman Warrior" then
                Mon = "Fishman Warrior"
                LevelQuest = 1
                NameQuest = "FishmanQuest"
                NameMon = "Fishman Warrior"
                CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
                CFrameMon = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625)
                if _G.AutoFarm and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
                end
            elseif (MyLevel >= 400 and MyLevel <= 449) or SelectMonster == "Fishman Commando" then
                Mon = "Fishman Commando"
                LevelQuest = 2
                NameQuest = "FishmanQuest"
                NameMon = "Fishman Commando"
                CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
                CFrameMon = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875)
                if _G.AutoFarm and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
                end
            elseif (MyLevel >= 450 and MyLevel <= 474) or SelectMonster == "God's Guard" then
                Mon = "God's Guard"
                LevelQuest = 1
                NameQuest = "SkyExp1Quest"
                NameMon = "God's Guard"
                CFrameQuest = CFrame.new(-4721.88867, 843.874695, -1949.96643, 0.996191859, -0, -0.0871884301, 0, 1, -0, 0.0871884301, 0, 0.996191859)
                CFrameMon = CFrame.new(-4710.04296875, 845.2769775390625, -1927.3079833984375)
                if _G.AutoFarm and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
                end
            elseif (MyLevel >= 475 and MyLevel <= 524) or SelectMonster == "Shanda" then
                Mon = "Shanda"
                LevelQuest = 2
                NameQuest = "SkyExp1Quest"
                NameMon = "Shanda"
                CFrameQuest = CFrame.new(-7859.09814, 5544.19043, -381.476196, -0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, -0.422592998)
                CFrameMon = CFrame.new(-7678.48974609375, 5566.40380859375, -497.2156066894531)
                if _G.AutoFarm and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
                end
            elseif (MyLevel >= 525 and MyLevel <= 549) or SelectMonster == "Royal Squad" then
                Mon = "Royal Squad"
                LevelQuest = 1
                NameQuest = "SkyExp2Quest"
                NameMon = "Royal Squad"
                CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                CFrameMon = CFrame.new(-7624.25244140625, 5658.13330078125, -1467.354248046875)
            elseif (MyLevel >= 550 and MyLevel <= 624) or SelectMonster == "Royal Soldier" then
                Mon = "Royal Soldier"
                LevelQuest = 2
                NameQuest = "SkyExp2Quest"
                NameMon = "Royal Soldier"
                CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                CFrameMon = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625)
            elseif (MyLevel >= 625 and MyLevel <= 649) or SelectMonster == "Galley Pirate" then
                Mon = "Galley Pirate"
                LevelQuest = 1
                NameQuest = "FountainQuest"
                NameMon = "Galley Pirate"
                CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381)
                CFrameMon = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875)
            elseif MyLevel >= 650 or SelectMonster == "Galley Captain" then
                Mon = "Galley Captain"
                LevelQuest = 2
                NameQuest = "FountainQuest"
                NameMon = "Galley Captain"
                CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381)
                CFrameMon = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375)
            end
           elseif World2 then
            if (MyLevel >= 700 and MyLevel <= 724) or SelectMonster == "Raider" then
                Mon = "Raider"
                LevelQuest = 1
                NameQuest = "Area1Quest"
                NameMon = "Raider"
                CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
                CFrameMon = CFrame.new(-728.3267211914062, 52.779319763183594, 2345.7705078125)
            elseif (MyLevel >= 725 and MyLevel <= 774) or SelectMonster == "Mercenary" then
                Mon = "Mercenary"
                LevelQuest = 2
                NameQuest = "Area1Quest"
                NameMon = "Mercenary"
                CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
                CFrameMon = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625)
            elseif (MyLevel >= 775 and MyLevel <= 799) or SelectMonster == "Swan Pirate" then
                Mon = "Swan Pirate"
                LevelQuest = 1
                NameQuest = "Area2Quest"
                NameMon = "Swan Pirate"
                CFrameQuest = CFrame.new(638.43811, 71.769989, 918.282898, 0.139203906, 0, 0.99026376, 0, 1, 0, -0.99026376, 0, 0.139203906)
                CFrameMon = CFrame.new(1068.664306640625, 137.61428833007812, 1322.1060791015625)
            elseif (MyLevel >= 800 and MyLevel <= 874) or SelectMonster == "Factory Staff" then
                Mon = "Factory Staff"
                NameQuest = "Area2Quest"
                LevelQuest = 2
                NameMon = "Factory Staff"
                CFrameQuest = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881e-10, -0.999488771, 1.36326533e-10, 1, 8.92172336e-10, 0.999488771, -1.07732087e-10, -0.0319722369)
                CFrameMon = CFrame.new(73.07867431640625, 81.86344146728516, -27.470672607421875)
            elseif (MyLevel >= 875 and MyLevel <= 899) or SelectMonster == "Marine Lieutenant" then
                Mon = "Marine Lieutenant"
                LevelQuest = 1
                NameQuest = "MarineQuest3"
                NameMon = "Marine Lieutenant"
                CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
                CFrameMon = CFrame.new(-2821.372314453125, 75.89727783203125, -3070.089111328125)
            elseif (MyLevel >= 900 and MyLevel <= 949) or SelectMonster == "Marine Captain" then
                Mon = "Marine Captain"
                LevelQuest = 2
                NameQuest = "MarineQuest3"
                NameMon = "Marine Captain"
                CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
                CFrameMon = CFrame.new(-1861.2310791015625, 80.17658233642578, -3254.697509765625)
            elseif (MyLevel >= 950 and MyLevel <= 974) or SelectMonster == "Zombie" then
                Mon = "Zombie"
                LevelQuest = 1
                NameQuest = "ZombieQuest"
                NameMon = "Zombie"
                CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146)
                CFrameMon = CFrame.new(-5657.77685546875, 78.96973419189453, -928.68701171875)
            elseif (MyLevel >= 975 and MyLevel <= 999) or SelectMonster == "Vampire" then
                Mon = "Vampire"
                LevelQuest = 2
                NameQuest = "ZombieQuest"
                NameMon = "Vampire"
                CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146)
                CFrameMon = CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625)
            elseif (MyLevel >= 1000 and MyLevel <= 1049) or SelectMonster == "Snow Trooper" then
                Mon = "Snow Trooper"
                LevelQuest = 1
                NameQuest = "SnowMountainQuest"
                NameMon = "Snow Trooper"
                CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
                CFrameMon = CFrame.new(549.1473388671875, 427.3870544433594, -5563.69873046875)
            elseif (MyLevel >= 1050 and MyLevel <= 1099) or SelectMonster == "Winter Warrior" then
                Mon = "Winter Warrior"
                LevelQuest = 2
                NameQuest = "SnowMountainQuest"
                NameMon = "Winter Warrior"
                CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
                CFrameMon = CFrame.new(1142.7451171875, 475.6398010253906, -5199.41650390625)
            elseif (MyLevel >= 1100 and MyLevel <= 1124) or SelectMonster == "Lab Subordinate" then
                Mon = "Lab Subordinate"
                LevelQuest = 1
                NameQuest = "IceSideQuest"
                NameMon = "Lab Subordinate"
                CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, 0, 1, -0, 0.891015649, 0, 0.453972578)
                CFrameMon = CFrame.new(-5707.4716796875, 15.951709747314453, -4513.39208984375)
            elseif (MyLevel >= 1125 and MyLevel <= 1174) or SelectMonster == "Horned Warrior" then
                Mon = "Horned Warrior"
                LevelQuest = 2
                NameQuest = "IceSideQuest"
                NameMon = "Horned Warrior"
                CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, 0, 1, -0, 0.891015649, 0, 0.453972578)
                CFrameMon = CFrame.new(-6341.36669921875, 15.951770782470703, -5723.162109375)
            elseif (MyLevel >= 1175 and MyLevel <= 1199) or SelectMonster == "Magma Ninja" then
                Mon = "Magma Ninja"
                LevelQuest = 1
                NameQuest = "FireSideQuest"
                NameMon = "Magma Ninja"
                CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
                CFrameMon = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375)
            elseif (MyLevel >= 1200 and MyLevel <= 1249) or SelectMonster == "Lava Pirate" then
                Mon = "Lava Pirate"
                LevelQuest = 2
                NameQuest = "FireSideQuest"
                NameMon = "Lava Pirate"
                CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
                CFrameMon = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875)
            elseif (MyLevel >= 1250 and MyLevel <= 1274) or SelectMonster == "Ship Deckhand" then
                Mon = "Ship Deckhand"
                LevelQuest = 1
                NameQuest = "ShipQuest1"
                NameMon = "Ship Deckhand"
                CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6016)
                CFrameMon = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375)
                if _G.AutoFarm and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                end
            elseif (MyLevel >= 1275 and MyLevel <= 1299) or SelectMonster == "Ship Engineer" then
                Mon = "Ship Engineer"
                LevelQuest = 2
                NameQuest = "ShipQuest1"
                NameMon = "Ship Engineer"
                CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6016)
                CFrameMon = CFrame.new(919.4786376953125, 43.54401397705078, 32779.96875)
                if _G.AutoFarm and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                end
            elseif (MyLevel >= 1300 and MyLevel <= 1324) or SelectMonster == "Ship Steward" then
                Mon = "Ship Steward"
                LevelQuest = 1
                NameQuest = "ShipQuest2"
                NameMon = "Ship Steward"
                CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125)
                CFrameMon = CFrame.new(919.4385375976562, 129.55599975585938, 33436.03515625)
                if _G.AutoFarm and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                end
            elseif (MyLevel >= 1325 and MyLevel <= 1349) or SelectMonster == "Ship Officer" then
                Mon = "Ship Officer"
                LevelQuest = 2
                NameQuest = "ShipQuest2"
                NameMon = "Ship Officer"
                CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125)
                CFrameMon = CFrame.new(1036.0179443359375, 181.4390411376953, 33315.7265625)
                if _G.AutoFarm and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                end
            elseif (MyLevel >= 1350 and MyLevel <= 1374) or SelectMonster == "Arctic Warrior" then
                Mon = "Arctic Warrior"
                LevelQuest = 1
                NameQuest = "FrostQuest"
                NameMon = "Arctic Warrior"
                CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909)
                CFrameMon = CFrame.new(5966.24609375, 62.97002029418945, -6179.3828125)
                if _G.AutoFarm and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-6508.5581054688, 5000.034996032715, -132.83953857422))
                end
            elseif (MyLevel >= 1375 and MyLevel <= 1424) or SelectMonster == "Snow Lurker" then
                Mon = "Snow Lurker"
                LevelQuest = 2
                NameQuest = "FrostQuest"
                NameMon = "Snow Lurker"
                CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909)
                CFrameMon = CFrame.new(5407.07373046875, 69.19437408447266, -6880.88037109375)
            elseif (MyLevel >= 1425 and MyLevel <= 1449) or SelectMonster == "Sea Soldier" then
                Mon = "Sea Soldier"
                LevelQuest = 1
                NameQuest = "ForgottenQuest"
                NameMon = "Sea Soldier"
                CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376)
                CFrameMon = CFrame.new(-3028.2236328125, 64.67451477050781, -9775.4267578125)
            elseif MyLevel >= 1450 or SelectMonster == "Water Fighter" then
                Mon = "Water Fighter"
                LevelQuest = 2
                NameQuest = "ForgottenQuest"
                NameMon = "Water Fighter"
                CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376)
                CFrameMon = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875)
            end
                elseif World3 then
           if (MyLevel >= 1500 and MyLevel <= 1524) or SelectMonster == "Pirate Millionaire" then
                Mon = "Pirate Millionaire"
                LevelQuest = 1
                NameQuest = "PiratePortQuest"
                NameMon = "Pirate Millionaire"
                CFrameQuest = CFrame.new(-450.104645, 107.681458, 5950.72607, 0.957107544, -0, -0.289732844, 0, 1, -0, 0.289732844, 0, 0.957107544)
                CFrameMon = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)
            elseif (MyLevel >= 1525 and MyLevel <= 1574) or SelectMonster == "Pistol Billionaire" then
                Mon = "Pistol Billionaire"
                LevelQuest = 2
                NameQuest = "PiratePortQuest"
                NameMon = "Pistol Billionaire"
                CFrameQuest = CFrame.new(-450.104645, 107.681458, 5950.72607, 0.957107544, -0, -0.289732844, 0, 1, -0, 0.289732844, 0, 0.957107544)
                CFrameMon = CFrame.new(-54.8110352, 83.7698746, 5947.84082, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
            elseif (MyLevel >= 1575 and MyLevel <= 1599) or SelectMonster == "Dragon Crew Warrior" then
                Mon = "Dragon Crew Warrior"
                LevelQuest = 1
                NameQuest = "DragonCrewQuest"
                NameMon = "Dragon Crew Warrior"
                CFrameQuest = CFrame.new(6750.4931640625, 127.44916534423828, -711.0308837890625)
                CFrameMon = CFrame.new(6709.76367, 52.3442993, -1139.02966, -0.763515472, 0, 0.645789504, 0, 1, 0, -0.645789504, 0, -0.763515472)
            elseif (MyLevel >= 1600 and MyLevel <= 1624) or SelectMonster == "Dragon Crew Archer" then
                Mon = "Dragon Crew Archer"
                NameQuest = "DragonCrewQuest"
                LevelQuest = 2
                NameMon = "Dragon Crew Archer"
                CFrameQuest = CFrame.new(6750.4931640625, 127.44916534423828, -711.0308837890625)
                CFrameMon = CFrame.new(6668.76172, 481.376923, 329.12207, -0.121787429, 0, -0.992556155, 0, 1, 0, 0.992556155, 0, -0.121787429)
            elseif (MyLevel >= 1625 and MyLevel <= 1649) or SelectMonster == "Hydra Enforcer" then
                Mon = "Hydra Enforcer"
                NameQuest = "VenomCrewQuest"
                LevelQuest = 1
                NameMon = "Hydra Enforcer"
                CFrameQuest = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875)
                CFrameMon = CFrame.new(4547.11523, 1003.10217, 334.194824, 0.388810456, -0, -0.921317935, 0, 1, -0, 0.921317935, 0, 0.388810456)
            elseif (MyLevel >= 1650 and MyLevel <= 1699) or SelectMonster == "Venomous Assailant" then
                Mon = "Venomous Assailant"
                NameQuest = "VenomCrewQuest"
                LevelQuest = 2
                NameMon = "Venomous Assailant"
                CFrameQuest = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875)
                CFrameMon = CFrame.new(4674.92676, 1134.82654, 996.308838, 0.731321394, -0, -0.682033002, 0, 1, -0, 0.682033002, 0, 0.731321394)
            elseif (MyLevel >= 1700 and MyLevel <= 1724) or SelectMonster == "Marine Commodore" then
                Mon = "Marine Commodore"
                LevelQuest = 1
                NameQuest = "MarineTreeIsland"
                NameMon = "Marine Commodore"
                CFrameQuest = CFrame.new(2481.09228515625, 74.27049255371094, -6779.640625)
                CFrameMon = CFrame.new(2577.25391, 75.6100006, -7739.87207, 0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, 0.499959469)
            elseif (MyLevel >= 1725 and MyLevel <= 1774) or SelectMonster == "Marine Rear Admiral" then
                Mon = "Marine Rear Admiral"
                LevelQuest = 2
                NameQuest = "MarineTreeIsland"
                NameMon = "Marine Rear Admiral"
                CFrameQuest = CFrame.new(2481.09228515625, 74.27049255371094, -6779.640625)
                CFrameMon = CFrame.new(3761.81006, 123.912003, -6823.52197, 0.961273968, 0, 0.275594592, 0, 1, 0, -0.275594592, 0, 0.961273968)
            elseif (MyLevel >= 1775 and MyLevel <= 1799) or SelectMonster == "Fishman Raider" then
                Mon = "Fishman Raider"
                LevelQuest = 1
                NameQuest = "DeepForestIsland3"
                NameMon = "Fishman Raider"
                CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
                CFrameMon = CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625)
            elseif (MyLevel >= 1800 and MyLevel <= 1824) or SelectMonster == "Fishman Captain" then
                Mon = "Fishman Captain"
                LevelQuest = 2
                NameQuest = "DeepForestIsland3"
                NameMon = "Fishman Captain"
                CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
                CFrameMon = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625)
            elseif (MyLevel >= 1825 and MyLevel <= 1849) or SelectMonster == "Forest Pirate" then
                Mon = "Forest Pirate"
                LevelQuest = 1
                NameQuest = "DeepForestIsland"
                NameMon = "Forest Pirate"
                CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
                CFrameMon = CFrame.new(-13274.478515625, 332.3781433105469, -7769.58056640625)
            elseif (MyLevel >= 1850 and MyLevel <= 1899) or SelectMonster == "Mythological Pirate" then
                Mon = "Mythological Pirate"
                LevelQuest = 2
                NameQuest = "DeepForestIsland"
                NameMon = "Mythological Pirate"
                CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
                CFrameMon = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
            elseif (MyLevel >= 1900 and MyLevel <= 1924) or SelectMonster == "Jungle Pirate" then
                Mon = "Jungle Pirate"
                LevelQuest = 1
                NameQuest = "DeepForestIsland2"
                NameMon = "Jungle Pirate"
                CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
                CFrameMon = CFrame.new(-12256.16015625, 331.73828125, -10485.8369140625)
            elseif (MyLevel >= 1925 and MyLevel <= 1974) or SelectMonster == "Musketeer Pirate" then
                Mon = "Musketeer Pirate"
                LevelQuest = 2
                NameQuest = "DeepForestIsland2"
                NameMon = "Musketeer Pirate"
                CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
                CFrameMon = CFrame.new(-13457.904296875, 391.545654296875, -9859.177734375)
            elseif (MyLevel >= 1975 and MyLevel <= 1999) or SelectMonster == "Reborn Skeleton" then
                Mon = "Reborn Skeleton"
                LevelQuest = 1
                NameQuest = "HauntedQuest1"
                NameMon = "Reborn Skeleton"
                CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
                CFrameMon = CFrame.new(-8763.7236328125, 165.72299194335938, 6159.86181640625)
            elseif (MyLevel >= 2000 and MyLevel <= 2024) or SelectMonster == "Living Zombie" then
                Mon = "Living Zombie"
                LevelQuest = 2
                NameQuest = "HauntedQuest1"
                NameMon = "Living Zombie"
                CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
                CFrameMon = CFrame.new(-10144.1318359375, 138.62667846679688, 5838.0888671875)
            elseif (MyLevel >= 2025 and MyLevel <= 2049) or SelectMonster == "Demonic Soul" then
                Mon = "Demonic Soul"
                LevelQuest = 1
                NameQuest = "HauntedQuest2"
                NameMon = "Demonic Soul"
                CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                CFrameMon = CFrame.new(-9505.8720703125, 172.10482788085938, 6158.9931640625)
            elseif (MyLevel >= 2050 and MyLevel <= 2074) or SelectMonster == "Posessed Mummy" then
                Mon = "Posessed Mummy"
                LevelQuest = 2
                NameQuest = "HauntedQuest2"
                NameMon = "Posessed Mummy"
                CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                CFrameMon = CFrame.new(-9582.0224609375, 6.251527309417725, 6205.478515625)
            elseif (MyLevel >= 2075 and MyLevel <= 2099) or SelectMonster == "Peanut Scout" then
                Mon = "Peanut Scout"
                LevelQuest = 1
                NameQuest = "NutsIslandQuest"
                NameMon = "Peanut Scout"
                CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                CFrameMon = CFrame.new(-2143.241943359375, 47.72198486328125, -10029.9951171875)
            elseif (MyLevel >= 2100 and MyLevel <= 2124) or SelectMonster == "Peanut President" then
                Mon = "Peanut President"
                LevelQuest = 2
                NameQuest = "NutsIslandQuest"
                NameMon = "Peanut President"
                CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                CFrameMon = CFrame.new(-1859.35400390625, 38.10316848754883, -10422.4296875)
            elseif (MyLevel >= 2125 and MyLevel <= 2149) or SelectMonster == "Ice Cream Chef" then
                Mon = "Ice Cream Chef"
                LevelQuest = 1
                NameQuest = "IceCreamIslandQuest"
                NameMon = "Ice Cream Chef"
                CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                CFrameMon = CFrame.new(-872.24658203125, 65.81957244873047, -10919.95703125)
            elseif (MyLevel >= 2150 and MyLevel <= 2199) or SelectMonster == "Ice Cream Commander" then
                Mon = "Ice Cream Commander"
                LevelQuest = 2
                NameQuest = "IceCreamIslandQuest"
                NameMon = "Ice Cream Commander"
                CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                CFrameMon = CFrame.new(-558.06103515625, 112.04895782470703, -11290.7744140625)
            elseif (MyLevel >= 2200 and MyLevel <= 2224) or SelectMonster == "Cookie Crafter" then
                Mon = "Cookie Crafter"
                LevelQuest = 1
                NameQuest = "CakeQuest1"
                NameMon = "Cookie Crafter"
                CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
                CFrameMon = CFrame.new(-2374.13671875, 37.79826354980469, -12125.30859375)
            elseif (MyLevel >= 2225 and MyLevel <= 2249) or SelectMonster == "Cake Guard" then
                Mon = "Cake Guard"
                LevelQuest = 2
                NameQuest = "CakeQuest1"
                NameMon = "Cake Guard"
                CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
                CFrameMon = CFrame.new(-1598.3070068359375, 43.773197174072266, -12244.5810546875)
            elseif (MyLevel >= 2250 and MyLevel <= 2274) or SelectMonster == "Baking Staff" then
                Mon = "Baking Staff"
                LevelQuest = 1
                NameQuest = "CakeQuest2"
                NameMon = "Baking Staff"
                CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
                CFrameMon = CFrame.new(-1887.8099365234375, 77.6185073852539, -12998.3505859375)
            elseif (MyLevel >= 2275 and MyLevel <= 2299) or SelectMonster == "Head Baker" then
                Mon = "Head Baker"
                LevelQuest = 2
                NameQuest = "CakeQuest2"
                NameMon = "Head Baker"
                CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
                CFrameMon = CFrame.new(-2216.188232421875, 82.884521484375, -12869.2939453125)
            elseif (MyLevel >= 2300 and MyLevel <= 2324) or SelectMonster == "Cocoa Warrior" then
                Mon = "Cocoa Warrior"
                LevelQuest = 1
                NameQuest = "ChocQuest1"
                NameMon = "Cocoa Warrior"
                CFrameQuest = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
                CFrameMon = CFrame.new(-21.55328369140625, 80.57499694824219, -12352.3876953125)
            elseif (MyLevel >= 2325 and MyLevel <= 2349) or SelectMonster == "Chocolate Bar Battler" then
                Mon = "Chocolate Bar Battler"
                LevelQuest = 2
                NameQuest = "ChocQuest1"
                NameMon = "Chocolate Bar Battler"
                CFrameQuest = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
                CFrameMon = CFrame.new(582.590576171875, 77.18809509277344, -12463.162109375)
            elseif (MyLevel >= 2350 and MyLevel <= 2374) or SelectMonster == "Sweet Thief" then
                Mon = "Sweet Thief"
                LevelQuest = 1
                NameQuest = "ChocQuest2"
                NameMon = "Sweet Thief"
                CFrameQuest = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
                CFrameMon = CFrame.new(165.1884765625, 76.05885314941406, -12600.8369140625)
            elseif (MyLevel >= 2375 and MyLevel <= 2399) or SelectMonster == "Candy Rebel" then
                Mon = "Candy Rebel"
                LevelQuest = 2
                NameQuest = "ChocQuest2"
                NameMon = "Candy Rebel"
                CFrameQuest = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
                CFrameMon = CFrame.new(134.86563110351562, 77.2476806640625, -12876.5478515625)
            elseif (MyLevel >= 2400 and MyLevel <= 2424) or SelectMonster == "Candy Pirate" then
                Mon = "Candy Pirate"
                LevelQuest = 1
                NameQuest = "CandyQuest1"
                NameMon = "Candy Pirate"
                CFrameQuest = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
                CFrameMon = CFrame.new(-1310.5003662109375, 26.016523361206055, -14562.404296875)
            elseif (MyLevel >= 2425 and MyLevel <= 2449) or SelectMonster == "Snow Demon" then
                Mon = "Snow Demon"
                LevelQuest = 2
                NameQuest = "CandyQuest1"
                NameMon = "Snow Demon"
                CFrameQuest = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
                CFrameMon = CFrame.new(-880.2006225585938, 71.24776458740234, -14538.609375)
            elseif (MyLevel >= 2450 and MyLevel <= 2474) or SelectMonster == "Isle Outlaw" then
                Mon = "Isle Outlaw"
                LevelQuest = 1
                NameQuest = "TikiQuest1"
                NameMon = "Isle Outlaw"
                CFrameQuest = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
                CFrameMon = CFrame.new(-16442.814453125, 116.13899993896484, -264.4637756347656)
            elseif (MyLevel >= 2475 and MyLevel <= 2524) or SelectMonster == "Island Boy" then
                Mon = "Island Boy"
                LevelQuest = 2
                NameQuest = "TikiQuest1"
                NameMon = "Island Boy"
                CFrameQuest = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
                CFrameMon = CFrame.new(-16901.26171875, 84.06756591796875, -192.88906860351562)
            elseif (MyLevel >= 2525 and MyLevel <= 2550) or SelectMonster == "Isle Champion" then
                Mon = "Isle Champion"
                LevelQuest = 2
                NameQuest = "TikiQuest2"
                NameMon = "Isle Champion"
                CFrameQuest = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625)
                CFrameMon = CFrame.new(-16641.6796875, 235.7825469970703, 1031.282958984375)
                elseif (MyLevel >= 2550 and MyLevel <= 2574) or SelectMonster == "Serpent Hunter" then
                Mon = "Serpent Hunter"
                LevelQuest = 1
                NameQuest = "TikiQuest3"
                NameMon = "Serpent Hunter"
                CFrameQuest = CFrame.new(-16665.1914, 104.596405, 1579.69434, 0.951068401, -0, -0.308980465, 0, 1, -0, 0.308980465, 0, 0.951068401)
                CFrameMon = CFrame.new(-16521.0625, 106.09285, 1488.78467, 0.469467044, 0, 0.882950008, 0, 1, 0, -0.882950008, 0, 0.469467044)
               elseif MyLevel >= 2575 or SelectMonster == "Skull Slayer" then
                Mon = "Skull Slayer"
                LevelQuest = 2
                NameQuest = "TikiQuest3"
                NameMon = "Skull Slayer"
                CFrameQuest = CFrame.new(-16665.1914, 104.596405, 1579.69434, 0.951068401, -0, -0.308980465, 0, 1, -0, 0.308980465, 0, 0.951068401)
                CFrameMon = CFrame.new(-16855.043, 122.457253, 1478.15308, -0.999392271, 0, -0.0348687991, 0, 1, 0, 0.0348687991, 0, -0.999392271)
            end
        end
    end

function Hop()
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    local Deleted = false
    function TPReturner()
        local Site;
        if foundAnything == "" then
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        end
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
        local num = 0;
        for i,v in pairs(Site.data) do
            local Possible = true
            ID = tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _,Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then
                            Possible = false
                        end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            local delFile = pcall(function()
                                AllIDs = {}
                                table.insert(AllIDs, actualHour)
                            end)
                        end
                    end
                    num = num + 1
                end
                if Possible == true then
                    table.insert(AllIDs, ID)
                    wait(.1)
                    pcall(function()

                        wait()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                    end)
                    wait(.1)
                end
            end
        end
    end
    function Teleport()
        while wait(.1) do
            pcall(function()
                TPReturner()
                if foundAnything ~= "" then
                    TPReturner()
                end
            end)
        end
    end
    Teleport()
end

function AutoHaki()
  local player = game:GetService("Players").LocalPlayer
  local character = player.Character
  if character and not character:FindFirstChild("HasBuso") then
    local remote = game:GetService("ReplicatedStorage").Remotes.CommF_
    if remote then
      remote:InvokeServer("Buso")
    end
  end
end
  function UnEquipWeapon(Weapon)
        if game.Players.LocalPlayer.Character:FindFirstChild(Weapon) then
            _G.NotAutoEquip = true
            wait(.5)
            game.Players.LocalPlayer.Character:FindFirstChild(Weapon).Parent = game.Players.LocalPlayer.Backpack
            wait(.1)
            _G.NotAutoEquip = false
        end
    end

    function EquipWeapon(ToolSe)
        if not _G.NotAutoEquip then
            if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) then
                Tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
                wait(.1)
                game.Players.LocalPlayer.Character.Humanoid:EquipTool(Tool)
            end
        end
    end

	spawn(function()
		local gg = getrawmetatable(game)
		local old = gg.__namecall
		setreadonly(gg,false)
		gg.__namecall = newcclosure(function(...)
		  local method = getnamecallmethod()
		  local args = {
			...
		  }
		  if tostring(method) == "FireServer" then
		  if tostring(args[1]) == "RemoteEvent" then
		  if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
		  if _G.UseSkill then
		  if type(args[2]) == "vector" then
		  args[2] = PositionSkillMasteryDevilFruit
		  else
			args[2] = CFrame.new(PositionSkillMasteryDevilFruit)
		  end
		  return old(unpack(args))
		  end
		  end
		  end
		  end
		  return old(...)
		  end)
        end)

spawn(function()
  pcall(function()
    while task.wait() do
    for i,v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
    if v:IsA("Tool") then
    if v:FindFirstChild("RemoteFunctionShoot") then
    CurrentEquipGun = v.Name
    end
    end
    end
    end
    end)
  end)

function StopTween(target)
    local plyr = game:GetService("Players").LocalPlayer
    local char = plyr.Character

    if not target then
        _G.StopTween = true
        wait(0.2)
        topos(char.HumanoidRootPart.CFrame)
        wait(0.2)
        if char.HumanoidRootPart:FindFirstChild("BodyClip") then
            char.HumanoidRootPart.BodyClip:Destroy()
        end
        if char:FindFirstChild("Block") then
            char.Block:Destroy()
        end
        _G.StopTween = false
        _G.Clip = false
    end

    if char:FindFirstChild("Highlight") then
        char.Highlight:Destroy()
    end
end

function LockTween()
    if _G.LockTween then
        return
    end
    _G.LockTween = true
    wait()
    local plyr = game.Players.LocalPlayer
    local char = plyr.Character
    if char and char:IsDescendantOf(game.Workspace) then
        local hrp = char:WaitForChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame
        end
    end
    wait()
    if char:FindFirstChild("BodyClip") then
        char.BodyClip:Destroy()
    end
    if char:FindFirstChild("PartTele") then
        char.Block:Destroy()
    end
    _G.LockTween = false
end

function BringMob(huh)
    for i, v in pairs(WS.Enemies:GetChildren()) do
        if v.Name == huh and v.Parent and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 350 then
            v.HumanoidRootPart.CFrame = BringPos
            v.Humanoid.JumpPower = 0
            v.Humanoid.WalkSpeed = 0
            v.HumanoidRootPart.Transparency = 1
            v.HumanoidRootPart.CanCollide = false
            v.Head.CanCollide = false
            if v.Humanoid:FindFirstChild("Animator") then
                v.Humanoid.Animator:Destroy()
            end
            if not v.HumanoidRootPart:FindFirstChild("Lock") then
                local lock = Instance.new("BodyVelocity")
                lock.Parent = v.HumanoidRootPart
                lock.Name = "Lock"
                lock.MaxForce = Vector3.new(100000, 100000, 100000)
                lock.Velocity = Vector3.new(0, 0, 0)
            end
            sethiddenproperty(plr, "SimulationRadius", math.huge)
            v.Humanoid:ChangeState(11)
        end
    end
end

function CancelTween23()
    if plr.Character.Head:FindFirstChild("BodyVelocity") then
        plr.Character.Head:FindFirstChild("BodyVelocity"):Destroy()
    end
    if plr.Character:FindFirstChild("PartTele") then
        plr.Character:FindFirstChild("PartTele"):Destroy()
    end
    NoClip = false
    return Tween23(plr.Character.HumanoidRootPart.CFrame)
end

function KillMob(V1, StopFunction)
    pcall(function()
        thismob = DetectMob2(V1)
        if thismob:FindFirstChild("HumanoidRootPart") and thismob.Parent and thismob:FindFirstChild("Humanoid") and thismob.Humanoid.Health > 0 then
            repeat task.wait()
                Buso()
                EquipWeapon()
                Tween23(thismob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                BringPos = thismob.HumanoidRootPart.CFrame
                BringMob(V1)
                NoClip = true
            until not thismob.Parent or not thismob:FindFirstChild("Humanoid") or thismob:FindFirstChild("Humanoid").Health <= 0 or not thismob:FindFirstChild("HumanoidRootPart") or StopFunction()
            NoClip = false
            CancelTween23()
        end
    end)
end

spawn(function()
    while wait() do
        pcall(function()
            if NoClip == true then
                if not plr.Character.Head:FindFirstChild("AustinaClipVelocity") then
                    local Bucaccho = Instance.new("BodyVelocity", plr.Character.Head)
                    Bucaccho.P = 1500
                    Bucaccho.Name = "AustinaClipVelocity"
                    Bucaccho.MaxForce = Vector3.new(0, 100000, 0)
                    Bucaccho.Velocity = Vector3.new(0, 0, 0)
                end
                for i, v in pairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            else
                if plr.Character.Head:FindFirstChild("AustinaClipVelocity") then
                    plr.Character.Head:FindFirstChild("AustinaClipVelocity"):Destroy()
                end
            end
        end)
    end
end)


spawn(function()
    while task.wait() do
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")

            if character.Humanoid.Health <= 0 or not hrp then
                if character:FindFirstChild("Block") then
                    character.Block:Destroy()
                end
            end
        end)
    end
end)

spawn(function()
    while task.wait() do
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")

            if character:FindFirstChild("Block") then
                if (hrp.Position - character.Block.Position).Magnitude >= 100 then
                    character.Block:Destroy()
                end
            end
        end)
    end
end)


function enableNoclip()
    if not game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
        local Noclip = Instance.new("BodyVelocity")
        Noclip.Name = "BodyClip"
        Noclip.Parent = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
        Noclip.MaxForce = Vector3.new(100000, 100000, 100000)
        Noclip.Velocity = Vector3.new(0, 0, 0)
    end
end

function disableNoclip()
    local bodyClip = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip")
    if bodyClip then
        bodyClip:Destroy()
    end
end

function disableCollisions()
    for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end
local success, Module = pcall(function()
    return getgenv().Module;
end);
spawn(function()
    pcall(function()
        while task.wait(0.2) do
            if getgenv().Module or
            _G.DefendVolcano or
              getgenv().AutoFarm
            then
                enableNoclip()
                disableCollisions()
            else
                disableNoclip()
            end
        end
    end)
end)


function EquipAllWeapon()
        pcall(function()
            for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v:IsA('Tool') and not (v.Name == "Summon Sea Beast" or v.Name == "Water Body" or v.Name == "Awakening") then
                    local ToolHumanoid = game.Players.LocalPlayer.Backpack:FindFirstChild(v.Name)
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(ToolHumanoid)
                    wait(1)
                end
            end
        end)
    end

local isTeleporting = false

function WaitHRP(q0)
    if not q0 then return end
    return q0.Character:WaitForChild("HumanoidRootPart", 9)
end

function CheckNearestTeleporter(aI)
    local vcspos = aI.Position
    local minDist = math.huge
    local chosenTeleport = nil
    local y = game.PlaceId

    local TableLocations = {}

    if y == 2753915549 then
        TableLocations = {
            ["Sky3"] = Vector3.new(-7894, 5547, -380),
            ["Sky3Exit"] = Vector3.new(-4607, 874, -1667),
            ["UnderWater"] = Vector3.new(61163, 11, 1819),
            ["Underwater City"] = Vector3.new(61165.19140625, 0.18704631924629211, 1897.379150390625),
            ["Pirate Village"] = Vector3.new(-1242.4625244140625, 4.787059783935547, 3901.282958984375),
            ["UnderwaterExit"] = Vector3.new(4050, -1, -1814)
        }
    elseif y == 4442272183 then
        TableLocations = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Swan Room"] = Vector3.new(2285, 15, 905),
            ["Cursed Ship"] = Vector3.new(923, 126, 32852),
            ["Zombie Island"] = Vector3.new(-6509, 83, -133)
        }
    elseif y == 7449423635 then
        TableLocations = {
            ["Floating Turtle"] = Vector3.new(-12462, 375, -7552),
            ["Hydra Island"] = Vector3.new(5657.88623046875, 1013.0790405273438, -335.4996337890625),
            ["Mansion"] = Vector3.new(-12462, 375, -7552),
            ["Castle"] = Vector3.new(-5036, 315, -3179),
            ["Dimensional Shift"] = Vector3.new(-2097.3447265625, 4776.24462890625, -15013.4990234375),
            ["Beautiful Pirate"] = Vector3.new(5319, 23, -93),
            ["Beautiful Room"] = Vector3.new(5314.58203, 22.5364361, -125.942276, 1, 2.14762768e-08, -1.99111154e-13, -2.14762768e-08, 1, -3.0510602e-08, 1.98455903e-13, 3.0510602e-08, 1),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103)
        }
    end

    for _, v in pairs(TableLocations) do
        local dist = (v - vcspos).Magnitude
        if dist < minDist then
            minDist = dist
            chosenTeleport = v
        end
    end

    local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    if minDist <= (vcspos - playerPos).Magnitude then
        return chosenTeleport
    end
end

function requestEntrance(teleportPos)
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", teleportPos)
    local char = game.Players.LocalPlayer.Character.HumanoidRootPart
    char.CFrame = char.CFrame + Vector3.new(0, 50, 0)
    task.wait(0.5)
end

function TelePPlayer(P)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = P
end


function topos(Pos)
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("HumanoidRootPart") then
        local Distance = (Pos.Position - plr.Character.HumanoidRootPart.Position).Magnitude
        if not Pos then
            return
        end
        local nearestTeleport = CheckNearestTeleporter(Pos)
        if nearestTeleport then
            requestEntrance(nearestTeleport)
        end
        if not plr.Character:FindFirstChild("PartTele") then
            local PartTele = Instance.new("Part", plr.Character)
            PartTele.Size = Vector3.new(10,1,10)
            PartTele.Name = "PartTele"
            PartTele.Anchored = true
            PartTele.Transparency = 1
            PartTele.CanCollide = true
            PartTele.CFrame = WaitHRP(plr).CFrame
            PartTele:GetPropertyChangedSignal("CFrame"):Connect(function()
                if not isTeleporting then return end
                task.wait()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    WaitHRP(plr).CFrame = PartTele.CFrame
                end
            end)
        end
        isTeleporting = true
        local Tween = game:GetService("TweenService"):Create(plr.Character.PartTele, TweenInfo.new(Distance / 360, Enum.EasingStyle.Linear), {CFrame = Pos})
        Tween:Play()
        Tween.Completed:Connect(function(status)
            if status == Enum.PlaybackState.Completed then
                if plr.Character:FindFirstChild("PartTele") then
                    plr.Character.PartTele:Destroy()
                end
                isTeleporting = false
            end
        end)
    end
end

function stopTeleport()
    isTeleporting = false
    local plr = game.Players.LocalPlayer
    if plr.Character:FindFirstChild("PartTele") then
        plr.Character.PartTele:Destroy()
    end
end

spawn(function()
    while task.wait() do
        if not isTeleporting then
            stopTeleport()
        end
    end
end)

spawn(function()
    local plr = game.Players.LocalPlayer
    while task.wait() do
        pcall(function()
            if plr.Character:FindFirstChild("PartTele") then
                if (plr.Character.HumanoidRootPart.Position - plr.Character.PartTele.Position).Magnitude >= 100 then
                    stopTeleport()
                end
            end
        end)
    end
end)

local plr = game.Players.LocalPlayer
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        stopTeleport()
    end)
end
plr.CharacterAdded:Connect(onCharacterAdded)
if plr.Character then
    onCharacterAdded(plr.Character)
end
function TP1(Pos)
    topos(Pos)
end

    spawn(function()
        while wait() do
            if _G.SpinPos then
                Pos = CFrame.new(0,PosY,-20)
                wait(0.1)
                Pos = CFrame.new(-20,PosY,0)
                wait(0.1)
                Pos = CFrame.new(0,PosY,20)
                wait(0.1)
                Pos = CFrame.new(20,PosY,0)
            else
                Pos = CFrame.new(0,PosY,0)
            end
        end
    end)

-----------------------------------------------------------------
 ---------------------------------------------------------------
    spawn(function()
			while task.wait() do
				pcall(function()
						if _G.FarmBone or _G.AutoFarm or _G.Pray or _G.Trylux or _G.Hallow or _G.FarmCake or _G.FarmDaiBan or _G.Greybeard or _G.CursedCaptain or _G.AutoDarkBoss or _G.ChiefWarden or _G.Trident or _G.Longsword or _G.GravityBlade or _G.SwodsFlail or _G.AutoRengoku or _G.SwodsDRTrident or _G.SwodCanvande or _G.SwodsBuddy or _G.SwodTwinHooks or _G.Fullykatakuri or _G.AutoBoss or _G.SwodCanvander or _G.AutoFarmMaterial or _G.AutoSecondSea or _G.ThirdSea or _G.AutoBartilo or _G.AutoFactory or _G.AutoRaidPirate or _G.AutoQuestYama or _G.AutoYamaQuest or AutoSaber or _G.DefendVolcano or _G.TPB or _G.SailBoat or _G.Autoterrorshark or _G.KillShark or _G.KillPiranha or _G.KillFishCrew or _G.AutoQuestRace or ProjectTrialPro or _G.TweenMGear or _G.AutoMysticIsland or AutoUpgradeRace or AutoRaceEvo1 or _G.AutoFarmFruits or _G.Autopole or _G.Autosaw or _G.AutoElitehunter or FarmMtrFruit or _G.AutoNear or _G.CollectBerry or _G.RipIndraKill or _G.FarmChocola or SoulGuitar or _G.AutoHolyTorch or _G.AutoGetTushita or _G.AutoYama or _G.AutoMobDragon or _G.AutoHydraTree or _G.TweenToKitsune or _G.AutoAzuerEmber or _G.TweenVolcano or _G.Dungeon or _G.AutoLawRaid or _G.TweenFruit or _G.Grabfruit or _G.TeleportIsland or _G.TeleportNPC or _G.SafeMode or _G.AutoPlayerHunter or _G.AutoKillPlayer or _G.TeleportPly then
						if not game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
							local Noclip = Instance.new("BodyVelocity")
							Noclip.Name = "BodyClip"
							Noclip.Parent = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
							Noclip.MaxForce = Vector3.new(100000,100000,100000)
							Noclip.Velocity = Vector3.new(0,0,0)
						end
					else
						game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
					end
				end)
			end
		end)

spawn(function()
  pcall(function()
    game:GetService("RunService").Stepped:Connect(function()
      if _G.FarmBone or _G.AutoFarm or _G.Pray or _G.Trylux or _G.Hallow or _G.FarmCake or _G.FarmDaiBan or _G.Fullykatakuri or _G.AutoBoss or _G.AutoMateria or _G.AutoSecondSea or _G.Greybeard or _G.CursedCaptain or _G.AutoDarkBoss or _G.ChiefWarden or _G.Trident or _G.Longsword or _G.GravityBlade or _G.SwodsFlail or _G.AutoRengoku or _G.SwodsDRTrident or _G.SwodCanvande or _G.SwodsBuddy or _G.SwodTwinHooks or _G.ThirdSea or _G.AutoBartilo or _G.AutoFactory or _G.AutoRaidPirate or _G.AutoQuestYama or _G.AutoYamaQuest or _G.AutoElitehunter or FarmMtrFruit or AutoUpgradeRace or _G.AutoFarmMaterial or AutoRaceEvo1 or AutoSaber or _G.Autopole or _G.SwodCanvander or _G.DefendVolcano or _G.SailBoat or _G.Autoterrorshark or _G.KillShark or _G.KillPiranha or _G.KillFishCrew or _G.AutoQuestRace or ProjectTrialPro or _G.AutoMysticIsland or _G.TweenMGear or _G.Autosaw or _G.AutoNear or _G.AutoFarmFruits or _G.CollectBerry or _G.RipIndraKill or _G.FarmChocola or SoulGuitar or _G.AutoHolyTorch or _G.AutoGetTushita or _G.AutoYama or _G.AutoMobDragon or _G.AutoHydraTree or _G.TweenToKitsune or _G.AutoAzuerEmber or _G.TweenVolcano or _G.Dungeon or _G.AutoLawRaid or _G.TweenFruit or _G.Grabfruit or _G.TeleportIsland or _G.TeleportNPC or _G.SafeMode or _G.AutoPlayerHunter or _G.AutoKillPlayer or _G.TeleportPly then
      for i,v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
      if v:IsA("BasePart") then
      v.CanCollide = false
      end
      end
      end
      end)
    end)
  end)

local stoppos = {}
function TP13(Pos)
    local Distance = (Pos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local tween = game:GetService("TweenService"):Create(
        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart,
        TweenInfo.new(Distance/325, Enum.EasingStyle.Linear),
        {CFrame = Pos}
    ):Play()

    function stoppos:Stop()
        tween:Cancel()
    end

    return stoppos
end


    function fastpos(Pos)
        Distance = (Pos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        Speed = 1000
        game:GetService("TweenService"):Create(
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),
            {CFrame = Pos}
        ):Play()
    end

    function slowpos(Pos)
        Distance = (Pos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        Speed = 150
        game:GetService("TweenService"):Create(
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),
            {CFrame = Pos}
        ):Play()
    end

    -- or (game:GetService("Workspace").Enemies:FindFirstChild("Shark") and _G.AutoKillShark) or (game:GetService("Workspace").Enemies:FindFirstChild("Terrorshark") and _G.AutoTerrorshark) or (game:GetService("Workspace").Enemies:FindFirstChild("Piranha") and _G.AutoKillPiranha) or (game:GetService("Workspace").Enemies:FindFirstChild("Fish Crew Member") and _G.AutoKillFishCrew)

    local stopboat = {}
function BTP(p)
    pcall(function()
        if (p.Position-game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude >= 1500 and not Auto_Raid and game.Players.LocalPlayer.Character.Humanoid.Health > 0 then
            repeat wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = p
                wait(.05)
                game.Players.LocalPlayer.Character.Head:Destroy()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = p
            until (p.Position-game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 1500 and game.Players.LocalPlayer.Character.Humanoid.Health > 0
        end
    end)
end

function TelePPlayer(P)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = P
end


--Tween Boats
function TPB(CFgo)
local tween_s = game:service"TweenService"
local info = TweenInfo.new((game:GetService("Workspace").Boats.PirateBrigade.VehicleSeat.CFrame.Position - CFgo.Position).Magnitude/300, Enum.EasingStyle.Linear)
tween = tween_s:Create(game:GetService("Workspace").Boats.PirateBrigade.VehicleSeat, info, {CFrame = CFgo})
tween:Play()

local tweenfunc = {}

function tweenfunc:Stop()
    tween:Cancel()
end

return tweenfunc
end

function TPP(CFgo)
if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health <= 0 or not game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") then tween:Cancel() repeat wait() until game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") and game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Health > 0 wait(7) return end
local tween_s = game:service"TweenService"
local info = TweenInfo.new((game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.Position - CFgo.Position).Magnitude/325, Enum.EasingStyle.Linear)
tween = tween_s:Create(game.Players.LocalPlayer.Character["HumanoidRootPart"], info, {CFrame = CFgo})
tween:Play()

local tweenfunc = {}

function tweenfunc:Stop()
    tween:Cancel()
end

return tweenfunc
end

    function StopTween(target)
        if not target then
            _G.StopTween = true
            wait()
            topos(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame)
            wait()
            if game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
            end
            _G.StopTween = false
            _G.Clip = false
        end
    end

    spawn(function()
        pcall(function()
            while wait() do
                for i,v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
                    if v:IsA("Tool") then
                        if v:FindFirstChild("RemoteFunctionShoot") then
                            _G.SelectWeaponGun = v.Name
                        end
                    end
                end
            end
        end)
    end)

    game:GetService("Players").LocalPlayer.Idled:connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)

    function CheckColorRipIndra()
        mmb = {}
        for r, v in next, game:GetService("Workspace").Map["Boat Castle"].Summoner.Circle:GetChildren() do
            if v:IsA("Part") and v:FindFirstChild("Part") and v.Part.BrickColor.Name == "Dark stone grey" then
                mmb[v.BrickColor.Name] = v
            end
        end
        return mmb
    end
    function ActivateColor(cw)
        haki = {["Hot pink"] = "Winter Sky", ["Really red"] ="Pure Red", ["Oyster"] = "Snow White"}
        runnay = haki[cw]
        if runnay then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("activateColor", runnay)
        end
    end
    function AutoActiveColorRip_Indra()
        for r, v in pairs(CheckColorRipIndra()) do
            ActivateColor(r)
            topos(v.CFrame)
            firetouchinterest(v.TouchInterest)
        end
    end

function CheckRace()
    local bf = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
    local c4 = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Alchemist", "1")
    if game.Players.LocalPlayer.Character:FindFirstChild("RaceTransformed") then
        return game:GetService('Players').LocalPlayer.Data.Race.Value .. " V4"
    end
    if bf == -2 then
        return game:GetService('Players').LocalPlayer.Data.Race.Value .. " V3"
    end
    if c4 == -2 then
        return game:GetService('Players').LocalPlayer.Data.Race.Value .. " V2"
    end
    return game:GetService('Players').LocalPlayer.Data.Race.Value .. " V1"
end

_G.TargTrial = nil
function targettrial()
    if _G.TargTrial ~= nil then return end
    local a = nil
    local b = 450
    for i,v in pairs(game.Players:GetChildren()) do
        c = (v.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if c <= b and v ~= game.Players.LocalPlayer then
            b = c
            a = v
        end
    end
    if a == nil then return end
    if _G.TargTrial ~= nil then return end
    _G.TargTrial = a
end


function CheckPirateBoat()
    local checkmmpb = {"PirateBrigade", "PirateBrigade"}
    for r, v in next, game:GetService("Workspace").Enemies:GetChildren() do
        if table.find(checkmmpb, v.Name) and v:FindFirstChild("Health") and v.Health.Value > 0 then
            return v
        end
    end
end

function CheckPirateBoat()
    local checkmmpb = {"FishBoat"}
    for r, v in next, game:GetService("Workspace").Enemies:GetChildren() do
        if table.find(checkmmpb, v.Name) and v:FindFirstChild("Health") and v.Health.Value > 0 then
            return v
        end
    end
end

function StoreFruit()
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and string.find(v.Name, "Fruit") then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit",v:GetAttribute("OriginalName"),v)
        end
    end
end

function TpEntrance(P)
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", P)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.X, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Y, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Z)
        wait(0.5)
    end

function CheckItemBPCRBPCR(name)
    chbp = {game.Players.LocalPlayer.Character,game.Players.LocalPlayer.Backpack}
    for i, v in pairs(chbp) do
        if v:FindFirstChild(name) then
            return v:FindFirstChild(name)
        end
    end
end

local Window = UIAdapter.Create(UILibrary, {
    Name = "Austina",
    Title = "Blox Fruits",
    Desc = "Blox Fruits",
})

local Main = Window:Tab("General","14477284625")

local AutoFarm = Main:Section("Auto Main Farm","Left")
local Settings = Main:Section("Settings Mastery","Right")

AutoFarm:Toggle("Fast Attack", true, function(value)
    _G.FastAttack = value
end)

AutoFarm:Slider("Fast Attack Distance", true, 20, 250, 100, function(value)
    _G.FastAttackDistance = value
end)

_G.SelectWeapon = "Melee"
  AutoFarm:Dropdown("Select Weapons",{"Melee","Sword","Gun","Blox Fruit"},{"Melee"},function(v)
    _G.SelectWeapon = v
     end)

    task.spawn(function()
        while wait() do
	    	pcall(function()
 			if _G.SelectWeapon == "Melee" then
				for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
					if v.ToolTip == "Melee" then
						if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
							_G.SelectWeapon = v.Name
						end
					end
				end
			elseif _G.SelectWeapon == "Sword" then
				for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
					if v.ToolTip == "Sword" then
						if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
							_G.SelectWeapon = v.Name
						end
					end
				end
			elseif _G.SelectWeapon == "Gun" then
				for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
					if v.ToolTip == "Gun" then
						if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
							_G.SelectWeapon = v.Name
						end
					end
				end
			elseif _G.SelectWeapon == "Blox Fruit" then
				for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
					if v.ToolTip == "Blox Fruit" then
						if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
				 			_G.SelectWeapon = v.Name
			    			end
	      				end
	    			end
		    	end
     		end)
     	end
    end)

   AutoFarm:Toggle("Auto Farm Level",false,function(value)
    _G.AutoFarm = value
      StopTween(_G.AutoFarm)
       end)

        spawn(function()
        while wait() do
            if _G.AutoFarm then
                pcall(function()
                    local QuestTitle = game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                    CheckQuest()
                    if not string.find(QuestTitle, NameMon) then
                        StartBring = false
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                    end
                    if game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false then
                        StartBring = false
                        if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude > 1500 then
						TP1(CFrameQuest)
						elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude < 1500 then
						TP1(CFrameQuest)
						end
					else
						TP1(CFrameQuest)
					end
					if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude <= 20 then
						game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest",NameQuest,LevelQuest)
                    end
                    elseif game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == true then
                        if string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "kissed") then
                            for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                                if string.find(v.Name,"kissed Warrior") then
                                    if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                        if string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) then
                                            repeat task.wait()
                                                EquipWeapon(_G.SelectWeapon)

                                                PosMon = v.HumanoidRootPart.CFrame
                                                topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                                v.HumanoidRootPart.CanCollide = false
                                                v.Humanoid.WalkSpeed = 0
                                                v.Head.CanCollide = false
                                                MonFarm = v.Name
                                                v.HumanoidRootPart.Size = Vector3.new(70,70,70)
                                                StartBring = true
                                                game:GetService'VirtualUser':CaptureController()
                                                game:GetService'VirtualUser':Button1Down(Vector2.new(1280, 672))
                                            until not _G.AutoFarm or v.Humanoid.Health <= 0 or not v.Parent or game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false
                                        else
                                            StartBring = false
                                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                                        end
                                    end
                                elseif string.find(v.Name,"kissed Warrior") == nil then
                                    TP1(CFrameMon)
                                    StartBring = false
                                    if game:GetService("ReplicatedStorage"):FindFirstChild(Mon) then
                                        TP1(game:GetService("ReplicatedStorage"):FindFirstChild(Mon).HumanoidRootPart.CFrame * CFrame.new(0,20,0))
                                    end
                                end
                            end
                        else
                            if game:GetService("Workspace").Enemies:FindFirstChild(Mon) then
                                for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                                    if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                        if v.Name == Mon then
                                            if string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) then
                                                repeat task.wait()
                                                    EquipWeapon(_G.SelectWeapon)
                                                     AutoHaki()
                                                    PosMon = v.HumanoidRootPart.CFrame
                                                    topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                                    v.HumanoidRootPart.CanCollide = false
                                                    v.Humanoid.WalkSpeed = 0
                                                    v.Head.CanCollide = false
                                                    v.HumanoidRootPart.Size = Vector3.new(70,70,70)
                                                    StartBring = true
                                                    MonFarm = v.Name
                                                    game:GetService'VirtualUser':CaptureController()
                                                    game:GetService'VirtualUser':Button1Down(Vector2.new(1280, 672))
                                                until not _G.AutoFarm or v.Humanoid.Health <= 0 or not v.Parent or game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false
                                            else
                                                StartBring = false
                                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                                            end
                                        end
                                    end
                                end
                            else
                                TP1(CFrameMon)
                                StartBring = false
                                if game:GetService("ReplicatedStorage"):FindFirstChild(Mon) then
                                    TP1(game:GetService("ReplicatedStorage"):FindFirstChild(Mon).HumanoidRootPart.CFrame * CFrame.new(0,20,0))
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)

  AutoFarm:Toggle("Auto Kill Near | Mob Aura", false,function(value)
         _G.AutoNear = value
        StopTween(_G.AutoNear)
    end)

     spawn(function()
    while wait() do
        if _G.AutoNear then
            pcall(function()
                for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        -- Check if within 5000 studs
                        local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        if distance <= 5000 then
                            repeat
                                wait(_G.Fast_Delay)
                                StartBring = true
                                AutoHaki()
                                EquipWeapon(_G.SelectWeapon)
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.CanCollide = false
                                FarmPos = v.HumanoidRootPart.CFrame
                                MonFarm = v.Name

                            until not _G.AutoNear or not v.Parent or v.Humanoid.Health <= 0 or not game.Workspace.Enemies:FindFirstChild(v.Name)
                            StartBring = false
                           end
                        end
                     end
                  end)
                end
             end
          end)

     AutoFarm:Seperator("Auto Farm Mastery")

     if World1 or World2 then
     AutoFarm:Dropdown("Select Regime Farm",{"Farm Level Mastery", "Farm Level Mastery No Quest"},{"Farm Level Mastery No Quest"},function(Value)
       _G.selectFruitFarm = Value
      end)
    end
      if World3 then
    AutoFarm:Dropdown("Select Regime Farm",{"Farm Level Mastery", "Farm Level Mastery No Quest","Farm Bone Mastery","Farm Cake Mastery"},{"Farm Level Mastery No Quest"},function(Value)
       _G.selectFruitFarm = Value
      end)
    end

      AutoFarm:Toggle("Auto Farm Mastery Fruit", false,function(value)
         _G.AutoFarmFruits = value
         StopTween(_G.AutoFarmFruits)
        end)

spawn(function()
    while task.wait() do
        if _G.UseSkill then
            pcall(function()
                for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                 if v.Name == MonFarm
                 and v:FindFirstChild("Humanoid")
                 and v:FindFirstChild("HumanoidRootPart")
                 and v.Humanoid.Health <= v.Humanoid.MaxHealth * KillPercent / 100 then
                 repeat
                 game:GetService("RunService").Heartbeat:Wait()
                 EquipWeapon(game.Players.LocalPlayer.Data.DevilFruit.Value)
                 topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                 PositionSkillMasteryDevilFruit = v.HumanoidRootPart.Position
                 local char = game.Players.LocalPlayer.Character
                 local fruitName = game.Players.LocalPlayer.Data.DevilFruit.Value
                 local fruit = char:FindFirstChild(fruitName)
                 if fruit then
                 fruit.MousePos.Value = PositionSkillMasteryDevilFruit
                 local DevilFruitMastery = fruit.Level.Value
                 if SkillZ and DevilFruitMastery >= 1 then
                 game:service("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
                 wait()
                 game:service("VirtualInputManager"):SendKeyEvent(false, "Z", false, game)
                 end
                 if SkillX and DevilFruitMastery >= 1 then
                 game:service("VirtualInputManager"):SendKeyEvent(true, "X", false, game)
                 wait()
                 game:service("VirtualInputManager"):SendKeyEvent(false, "X", false, game)
                 end
                 if SkillC and DevilFruitMastery >= 1 then
                 game:service("VirtualInputManager"):SendKeyEvent(true, "C", false, game)
                 wait()
                 game:service("VirtualInputManager"):SendKeyEvent(false, "C", false, game)
                 end
                 if SkillV and DevilFruitMastery >= 1 then
                 game:service("VirtualInputManager"):SendKeyEvent(true, "V", false, game)
                 wait()
                 game:service("VirtualInputManager"):SendKeyEvent(false, "V", false, game)
                 end
                 if SkillF and DevilFruitMastery >= 1 then
                 game:service("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
                 wait()
                game:service("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
                end
               end
             until not _G.AutoFarmFruits or not _G.UseSkill or v.Humanoid.Health == 0
             end
            end
           end)
          end
         end
       end)

spawn(function()
    while wait() do
        if _G.AutoFarmFruits and _G.selectFruitFarm == 'Farm Level Mastery No Quest' then
            pcall(function()
                CheckQuest()
                TP1(CFrameQuest)
            end)
            for i, v in pairs(game.Workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    if v.Name == Mon then
                        repeat wait(_G.Fast_Delay)
                            if v.Humanoid.Health <= v.Humanoid.MaxHealth * KillPercent / 100 then
                                _G.UseSkill = true
                            else
                                _G.UseSkill = false
                                bringmob = true
                                AutoHaki()
                                EquipWeapon(_G.SelectWeapon)
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.CanCollide = false
                                FarmPos = v.HumanoidRootPart.CFrame
                                MonFarm = v.Name
                            end
                        until not _G.AutoFarmFruits or not MasteryType == 'Farm Level Mastery No Quest' or not v.Parent or v.Humanoid.Health == 0 or not _G.selectFruitFarm == 'Farm Level Mastery No Quest'
                         bringmob = false
                        _G.UseSkill = false
                    end
                end
            end
        end
    end
end)

spawn(function()
    while wait() do
        if _G.AutoFarmFruits and _G.selectFruitFarm == 'Farm Level Mastery' then
            pcall(function()
                CheckQuest()
                if not string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) or game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                    TP1(CFrameQuest)
                end
                if (CFrameQuest.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                end
            end)
            if string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) or game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == true then
                if game:GetService("Workspace").Enemies:FindFirstChild(Mon) then
                    for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                            if v.Name == Mon then
                                repeat wait(_G.Fast_Delay)
                                    if v.Humanoid.Health <= v.Humanoid.MaxHealth * KillPercent / 100 then
                                        _G.UseSkill = true
                                    else
                                        _G.UseSkill = false
                                        bringmob = true
                                        AutoHaki()
                                        EquipWeapon(_G.SelectWeapon)
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                        v.HumanoidRootPart.Transparency = 1
                                        v.Humanoid.WalkSpeed = 0
                                        v.HumanoidRootPart.CanCollide = false
                                        FarmPos = v.HumanoidRootPart.CFrame
                                        MonFarm = v.Name
                                    end
                                until not _G.AutoFarmFruits or not MasteryType == 'Farm Level Mastery' or not v.Parent or v.Humanoid.Health == 0 or not _G.selectFruitFarm == 'Farm Level Mastery'
                                bringmob = false
                                _G.UseSkill = false
                            end
                        end
                    end
                end
            end
        end
    end
end)
spawn(function()
    while wait() do
        if _G.AutoFarmFruits and _G.selectFruitFarm == 'Farm Bone Mastery' then
            pcall(function()
                local boneframe = CFrame.new(-9508.5673828125, 142.1398468017578, 5737.3603515625)
                TP1(boneframe)
            end)
            for i, v in pairs(game.Workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    if v.Name == "Reborn Skeleton" or v.Name == "Living Zombie" or v.Name == "Demonic Soul" or v.Name == "Posessed Mummy" then
                        repeat wait(_G.Fast_Delay)
                            if v.Humanoid.Health <= v.Humanoid.MaxHealth * KillPercent / 100 then
                                _G.UseSkill = true

                            else
                                _G.UseSkill = false
                                bringmob = true
                                AutoHaki()
                                EquipWeapon(_G.SelectWeapon)
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.CanCollide = false
                                FarmPos = v.HumanoidRootPart.CFrame
                                MonFarm = v.Name
                            end
                        until not _G.AutoFarmFruits or not MasteryType == 'Farm Bone Mastery' or not v.Parent or v.Humanoid.Health == 0 or not _G.selectFruitFarm == 'Farm Bone Mastery'
                        bringmob = false
                        _G.UseSkill = false
                    end
                end
            end
            for i, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                if v.Name == "Reborn Skeleton" then
               topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
               elseif v.Name == "Living Zombie" then
               topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
               elseif v.Name == "Demonic Soul" then
               topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                elseif v.Name == "Posessed Mummy" then
               topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                end
            end
        end
    end
end)
spawn(function()
    while wait() do
        if _G.AutoFarmFruits and _G.selectFruitFarm == 'Farm Cake Mastery' then
            pcall(function()
                local cakepos = CFrame.new(-2130.80712890625, 69.95634460449219, -12327.83984375)
                TP1(cakepos)
            end)
            for i, v in pairs(game.Workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    if v.Name == "Cookie Crafter" or v.Name == "Cake Guard" or v.Name == "Baking Staff" or v.Name == "Head Baker" then
                        repeat wait(_G.Fast_Delay)
                            if v.Humanoid.Health <= v.Humanoid.MaxHealth * KillPercent / 100 then
                                _G.UseSkill = true
                            else
                                _G.UseSkill = false
                                bringmob = true
                                AutoHaki()
                                StartBring = false
                                EquipWeapon(_G.SelectWeapon)
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.CanCollide = false
                                FarmPos = v.HumanoidRootPart.CFrame
                                MonFarm = v.Name
                            end
                        until not _G.AutoFarmFruits or not MasteryType == 'Farm Cake Mastery' or not v.Parent or v.Humanoid.Health == 0 or not _G.selectFruitFarm == 'Farm Cake Mastery'
                        bringmob = false
                        _G.UseSkill = false
                    end
                end
            end
            for i, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                if v.Name == "Cookie Crafter" then
                    topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                elseif v.Name == "Cake Guard" then
                    topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                elseif v.Name == "Baking Staff" then
                    topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                elseif v.Name == "Head Baker" then
                    topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                end
            end
        end
    end
end)

      AutoFarm:Seperator("Auto Chest Farm")

       AutoFarm:Toggle("Auto Farm Chest", false,function(value)
         _G.FarmChest = value
         StopTween(_G.FarmChest)
        end)

    spawn(function()
	while wait() do
		if _G.FarmChest then
			local Players = game:GetService("Players")
			local Player = Players.LocalPlayer
			local Character = Player.Character or Player.CharacterAdded:Wait()
			local Position = Character:GetPivot().Position
			local CollectionService = game:GetService("CollectionService")
			local Chests = CollectionService:GetTagged("_ChestTagged")
			local Distance, Nearest = math.huge
			for i = 1, #Chests do
				local Chest = Chests[i]
				local Magnitude = (Chest:GetPivot().Position - Position).Magnitude
				if (not Chest:GetAttribute("IsDisabled") and (Magnitude < Distance)) then
					Distance, Nearest = Magnitude, Chest
				end
			end
			if Nearest then
				local ChestPosition = Nearest:GetPivot().Position
				local CFrameTarget = CFrame.new(ChestPosition)
				topos(CFrameTarget)
			end
		end
	end
end)

      AutoFarm:Seperator("Auto Collect Berry")

    AutoFarm:Toggle("Auto Farm Berries", false,function(value)
         _G.CollectBerry = value
         StopTween(_G.CollectBerry)
        end)

spawn(function()
    while wait() do
        if _G.CollectBerry then
            local Players = game:GetService("Players")
            local Player = Players.LocalPlayer
            local Character = Player.Character or Player.CharacterAdded:Wait()
            local Position = Character:GetPivot().Position
            local CollectionService = game:GetService("CollectionService")
            local BerryBushes = CollectionService:GetTagged("BerryBush")
            local Distance, NearestBush, NearestBerryName = math.huge, nil, nil

            for _, Bush in ipairs(BerryBushes) do
                for AttributeName, _ in pairs(Bush:GetAttributes()) do
                    local Magnitude = (Bush.Parent:GetPivot().Position - Position).Magnitude
                    if Magnitude < Distance then
                        Distance = Magnitude
                        NearestBush = Bush
                        NearestBerryName = AttributeName
                    end
                end
            end

            if NearestBush and NearestBerryName then
                local BushModel = NearestBush.Parent
                local BushCenter = BushModel:GetPivot().Position

                -- Bay vào trong bụi cây
                TP1(CFrame.new(BushCenter + Vector3.new(0, 2, 0)))
                task.wait(0.5)

                -- Tìm object thật sự là trái berry (theo tên attribute)
                local BerryPart = BushModel:FindFirstChild(NearestBerryName)
                if BerryPart and BerryPart:IsA("BasePart") then
                    -- Bay đến đúng vị trí trái berry
                    TP1(BerryPart.CFrame + Vector3.new(0, 1, 0)) -- bay hơi trên trái berry một tí
                    task.wait(0.3)

                    -- Nhấn E để nhặt berry
                    local VirtualInput = game:GetService("VirtualInputManager")
                    VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                    VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            else
                if _G.CollectBerryHop then
                    Hop()
                end
            end
        end
    end
end)


   if World3 then
       AutoFarm:Seperator("Bone Farm")

    Boneyou = AutoFarm:Label("Check Bone")

    spawn(function()
        while wait() do
            pcall(function()
                Boneyou:Set("Your Bone : "..(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Bones","Check")))
            end)
        end
    end)

     AutoFarm:Toggle("Auto Farm Bone", false,function(value)
         game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
     		_G.FarmBone = value
         StopTween(_G.FarmBone)
    end)

    spawn(function()
        while wait() do
            local boneframe = CFrame.new(-9508.5673828125, 142.1398468017578, 5737.3603515625)
            if _G.FarmBone and World3 then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - boneframe.Position).Magnitude > 2000 then
                            TP1(boneframe)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(boneframe)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - boneframe.Position).Magnitude < 2000 then
                            TP1(boneframe)
                        end
                    else
                        TP1(boneframe)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Reborn Skeleton") or game:GetService("Workspace").Enemies:FindFirstChild("Living Zombie") or game:GetService("Workspace").Enemies:FindFirstChild("Demonic Soul") or game:GetService("Workspace").Enemies:FindFirstChild("Posessed Mummy") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Reborn Skeleton" or v.Name == "Living Zombie" or v.Name == "Demonic Soul" or v.Name == "Posessed Mummy" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NoAttackAnimation = true
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.FarmBone or not v.Parent or v.Humanoid.Health <= 0
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-9506.234375, 172.130615234375, 6117.0771484375))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Reborn Skeleton" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Living Zombie" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Demonic Soul" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Posessed Mummy" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

        AutoFarm:Toggle("Seperator Hallow Scythe", false,function(value)
     	_G.Hallow = value
         StopTween(_G.Hallow)
       end)

       spawn(function()
    while wait() do
        if _G.Hallow then
            pcall(function()
                if game:GetService("Workspace").Enemies:FindFirstChild("Soul Reaper") then
                    for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if string.find(v.Name , "Soul Reaper") then
                            repeat task.wait()
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                game:GetService("VirtualUser"):CaptureController()
                                game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 670))
                                v.HumanoidRootPart.Transparency = 1
                            until v.Humanoid.Health <= 0 or _G.Hallow == false
                        end
                    end
                elseif game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Hallow Essence") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Hallow Essence") then
                    repeat TP1(CFrame.new(-8932.322265625, 146.83154296875, 6062.55078125)) wait() until (CFrame.new(-8932.322265625, 146.83154296875, 6062.55078125).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 8
                    EquipWeapon("Hallow Essence")
                else
                    if game:GetService("ReplicatedStorage"):FindFirstChild("Soul Reaper") then
                        TP1(game:GetService("ReplicatedStorage"):FindFirstChild("Soul Reaper").HumanoidRootPart.CFrame * CFrame.new(2,20,2))

                       end
                    end
                end)
             end
         end
     end)

      AutoFarm:Toggle("Auto Trade Bone", false,function(value)
     		_G.Rdbone = value
       end)

       spawn(function()
            while wait(.1) do
                if _G.Rdbone then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Bones","Buy",1,1)
                end
            end
         end)

         AutoFarm:Toggle("Auto Pray", false,function(value)
     		_G.Pray = value
       end)

       spawn(function()
        pcall(function()
            while wait(.1) do
                if _G.Pray then
                    TP1(CFrame.new(-8652.99707, 143.450119, 6170.50879, -0.983064115, -2.48005533e-10, 0.18326205, -1.78910387e-09, 1, -8.24392288e-09, -0.18326205, -8.43218029e-09, -0.983064115))
                    wait()
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("gravestoneEvent",1)
                end
            end
        end)
    end)

        AutoFarm:Toggle("Auto Try Luck", false,function(value)
     		_G.Trylux = value
       end)

       spawn(function()
        pcall(function()
            while wait(.1) do
                if _G.Trylux then
                    TP1(CFrame.new(-8652.99707, 143.450119, 6170.50879, -0.983064115, -2.48005533e-10, 0.18326205, -1.78910387e-09, 1, -8.24392288e-09, -0.18326205, -8.43218029e-09, -0.983064115))
                    wait()
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("gravestoneEvent",2)
                end
            end
        end)
    end)

       AutoFarm:Seperator("Tyrant of the Skies Farm")

       AutoFarm:Toggle("Auto Farm Tyrant of the Skies", false,function(value)
     	_G.FarmDaiBan = value
     	StopTween(_G.FarmDaiBan)
       end)
           local TyrantoftheSkies = CFrame.new(-16194.0048828125, 155.21844482421875, 1420.719970703125)
    local Plsmon = game:GetService("Workspace").Enemies
     task.spawn(function()
    while task.wait() do
        if _G.FarmDaiBan then
            pcall(function()
                if game:GetService("Workspace").Enemies:FindFirstChild("Tyrant of the Skies") then
                    for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if v.Name == "Tyrant of the Skies" then
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat
                                    task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0))
                                    NeedAttacking = true
                                until not _G.FarmDaiBan or not v.Parent or v.Humanoid.Health <= 0
                                wait(1)
                            end
                        end
                    end
                else
                    local foundMob = false
                    for _, mobName in pairs({"Isle Outlaw", "Island Boy", "Isle Champion", "Serpent Hunter", "Skull Slayer"}) do
                        if game:GetService("Workspace").Enemies:FindFirstChild(mobName) then
                            foundMob = true
                            break
                        end
                    end
                    if foundMob then
                        for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Isle Outlaw" or v.Name == "Island Boy" or v.Name == "Isle Champion" or v.Name == "Serpent Hunter" or v.Name == "Skull Slayer" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat
                                        task.wait()
                                        AutoHaki()
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        StartBring = true
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        PosMon = v.HumanoidRootPart.CFrame
                                        MonFarm = v.Name
                                        v.Head.CanCollide = false
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        NeedAttacking = true
                                        if v.Name == "Isle Outlaw" then
                                            Bring(v.Name, CFrame.new(-16442.814453125, 116.13899993896484, -264.4637756347656))
                                        elseif v.Name == "Island Boy" then
                                            Bring(v.Name, CFrame.new(-16901.26171875, 84.06756591796875, -192.88906860351562))
                                        elseif v.Name == "Isle Champion" then
                                            Bring(v.Name, CFrame.new(-16641.6796875, 235.7825469970703, 1031.282958984375))
                                        elseif v.Name == "Serpent Hunter" then
                                            Bring(v.Name, CFrame.new(-16521.0625, 106.09285, 1488.78467, 0.469467044, 0, 0.882950008, 0, 1, 0, -0.882950008, 0, 0.469467044))
                                            elseif v.Name == "Skull Slayer" then
                                            Bring(v.Name, CFrame.new(-16855.043, 122.457253, 1478.15308, -0.999392271, 0, -0.0348687991, 0, 1, 0, 0.0348687991, 0, -0.999392271))
                                        end
                                    until not _G.FarmDaiBan or not v.Parent or v.Humanoid.Health <= 0 or game:GetService("Workspace").Map.CakeLoaf.BigMirror.Other.Transparency == 0 or game:GetService("ReplicatedStorage"):FindFirstChild("Tyrant of the Skies [Lv. 2600] [Raid Boss]") or game:GetService("Workspace").Enemies:FindFirstChild("Tyrant of the Skies [Lv. 2600] [Raid Boss]")
                                    DamageAura = false
                                end
                            end
                        end
                    else
                        local RandomTele = math.random(1, 3)
                        if RandomTele == 1 then
                            topos(CFrame.new(-1436.86011, 167.753616, -12296.9512))
                        elseif RandomTele == 2 then
                            topos(CFrame.new(-2383.78979, 150.450592, -12126.4961))
                        elseif RandomTele == 3 then
                            topos(CFrame.new(-2231.2793, 168.256653, -12845.7559))
                        end
                    end
                    if BypassTP then
                        if (playerPos - TyrantoftheSkies.Position).Magnitude > 1500 then
                            BTP(TyrantoftheSkies)
                        else
                            topos(TyrantoftheSkies)
                        end
                    else
                        topos(TyrantoftheSkies)
                    end
                    UnEquipWeapon(_G.Selectweapon)
                    topos(CFrame.new(-16194.0048828125, 155.21844482421875, 1420.719970703125))
                end
            end)
        end
    end
end)

        AutoFarm:Seperator("Katakuri Farm")

   CakePrinceStatus = AutoFarm:Label("Check Cake Prince")
    task.spawn(function()
       while task.wait() do
          pcall(function()
           if string.len(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 88 then
           CakePrinceStatus:Set("Killed : "..string.sub(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),39,41)..' / 500')
          elseif string.len(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 87 then
          CakePrinceStatus:Set("Killed : "..string.sub(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),39,40)..' / 500')
           elseif string.len(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 86 then
        CakePrinceStatus:Set("Killed : "..string.sub(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),39,39)..' / 500')
        else
      CakePrinceStatus:Set("Prince King Spawned ✅")
      end
    end)
  end
  end)

       AutoFarm:Toggle("Auto Farm Cake Prince", false,function(value)
     	_G.FarmCake = value
     	StopTween(_G.FarmCake)
       end)

   local CakePos = CFrame.new(-2130.80712890625, 69.95634460449219, -12327.83984375)
    local Plsmon = game:GetService("Workspace").Enemies
     task.spawn(function()
    while task.wait() do
        if _G.FarmCake then
            pcall(function()
                if game:GetService("Workspace").Enemies:FindFirstChild("Cake Prince") then
                    for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if v.Name == "Cake Prince" then
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat
                                    task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    if game:GetService("Workspace")["_WorldOrigin"]:FindFirstChild("Ring") or game:GetService("Workspace")["_WorldOrigin"]:FindFirstChild("Fist") or game:GetService("Workspace")["_WorldOrigin"]:FindFirstChild("MochiSwirl") then
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0))
                                    else
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(4, 10, 10))
                                    end
                                    NeedAttacking = true
                                until not _G.FarmCake or not v.Parent or v.Humanoid.Health <= 0
                                wait(1)
                            end
                        end
                    end
                else
                    local foundMob = false
                    for _, mobName in pairs({"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}) do
                        if game:GetService("Workspace").Enemies:FindFirstChild(mobName) then
                            foundMob = true
                            break
                        end
                    end
                    if foundMob then
                        for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Cookie Crafter" or v.Name == "Cake Guard" or v.Name == "Baking Staff" or v.Name == "Head Baker" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat
                                        task.wait()
                                        AutoHaki()
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        StartBring = true
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        PosMon = v.HumanoidRootPart.CFrame
                                        MonFarm = v.Name
                                        v.Head.CanCollide = false
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        NeedAttacking = true
                                        if v.Name == "Cookie Crafter" then
                                            Bring(v.Name, CFrame.new(-2212.88965, 37.0051041, -11969.2568, 0.458114207, -0, -0.888893366, 0, 1, -0, 0.888893366, 0, 0.458114207))
                                        elseif v.Name == "Cake Guard" then
                                            Bring(v.Name, CFrame.new(-1693.98047, 35.2188225, -12436.8438, -0.716115236, 0, -0.697982132, 0, 1, 0, 0.697982132, 0, -0.716115236))
                                        elseif v.Name == "Baking Staff" then
                                            Bring(v.Name, CFrame.new(-1980.4375, 34.6653099, -12983.8408, -0.254338264, 0, -0.967115223, 0, 1, 0, 0.967115223, 0, -0.254338264))
                                        elseif v.Name == "Head Baker" then
                                            Bring(v.Name, CFrame.new(-2151.37793, 51.0095749, -13033.3975, -0.996587753, 0, 0.0825396702, 0, 1, 0, -0.0825396702, 0, -0.996587753))
                                        end
                                    until not _G.FarmCake or not v.Parent or v.Humanoid.Health <= 0 or game:GetService("Workspace").Map.CakeLoaf.BigMirror.Other.Transparency == 0 or game:GetService("ReplicatedStorage"):FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]") or game:GetService("Workspace").Enemies:FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]")
                                    DamageAura = false
                                end
                            end
                        end
                    else
                        local RandomTele = math.random(1, 3)
                        if RandomTele == 1 then
                            topos(CFrame.new(-1436.86011, 167.753616, -12296.9512))
                        elseif RandomTele == 2 then
                            topos(CFrame.new(-2383.78979, 150.450592, -12126.4961))
                        elseif RandomTele == 3 then
                            topos(CFrame.new(-2231.2793, 168.256653, -12845.7559))
                        end
                    end
                    if BypassTP then
                        if (playerPos - CakePos.Position).Magnitude > 1500 then
                            BTP(CakePos)
                        else
                            topos(CakePos)
                        end
                    else
                        topos(CakePos)
                    end
                    UnEquipWeapon(_G.Selectweapon)
                    topos(CFrame.new(-2130.80712890625, 69.95634460449219, -12327.83984375))
                end
            end)
        end
    end
end)

       AutoFarm:Toggle("Auto Katakuri V2", false,function(value)
     	_G.Fullykatakuri = value
    	StopTween(_G.Fullykatakuri)
       end)

   spawn(function()
		while wait() do
			if _G.Fullykatakuri then
				pcall(function()
					if game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") or game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice") then
						if string.find(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SweetChaliceNpc"),"Where") then
							game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SweetChaliceNpc")
						end
					elseif game.Players.LocalPlayer.Backpack:FindFirstChild("Sweet Chalice") or game.Players.LocalPlayer.Character:FindFirstChild("Sweet Chalice") then
						if string.find(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),"Do you want to open the portal now?") then
							game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")
						else
							if game.Workspace.Enemies:FindFirstChild("Baking Staff") or game.Workspace.Enemies:FindFirstChild("Head Baker") or game.Workspace.Enemies:FindFirstChild("Cake Guard") or game.Workspace.Enemies:FindFirstChild("Cookie Crafter")  then
								for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
									if (v.Name == "Baking Staff" or v.Name == "Head Baker" or v.Name == "Cake Guard" or v.Name == "Cookie Crafter") and v.Humanoid.Health > 0 then
										repeat wait()
											AutoHaki()
											EquipWeapon(_G.SelectWeapon)
											AutoHaki()
											PosMon = v.HumanoidRootPart.CFrame
											topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
											v.HumanoidRootPart.CanCollide = false
											v.Humanoid.WalkSpeed = 0
											v.Head.CanCollide = false
											attackGunEnemies(v.Name , 5)
											v.HumanoidRootPart.Size = Vector3.new(70,70,70)
											StartBring = false
											MonFarm = v.Name
											game:GetService'VirtualUser':CaptureController()
											game:GetService'VirtualUser':Button1Down(Vector2.new(1280, 672))
										until _G.Fullykatakuri == false or game:GetService("ReplicatedStorage"):FindFirstChild("Cake Prince") or not v.Parent or v.Humanoid.Health <= 0
									end
								end
							else
								CakeBring = false
								StartBring = false
								topos(CFrame.new(-1820.0634765625, 210.74781799316406, -12297.49609375))
							end
						end
					elseif game.ReplicatedStorage:FindFirstChild("Dough King") or game:GetService("Workspace").Enemies:FindFirstChild("Dough King") then
						if game:GetService("Workspace").Enemies:FindFirstChild("Dough King") then
							for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
								if v.Name == "Dough King" then
									repeat wait()
										AutoHaki()
										EquipWeapon(_G.SelectWeapon)
										v.HumanoidRootPart.Size = Vector3.new(70,70,70)
										v.HumanoidRootPart.CanCollide = false
										StartBring = false
										topos(v.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0))
							    		game:GetService'VirtualUser':CaptureController()
										game:GetService'VirtualUser':Button1Down(Vector2.new(1280, 672))
									until _G.Fullykatakuri == false or not v.Parent or v.Humanoid.Health <= 0
								end
							end
						else
							topos(CFrame.new(-2009.2802734375, 4532.97216796875, -14937.3076171875))
						end
					elseif game.Players.LocalPlayer.Backpack:FindFirstChild("Red Key") or game.Players.LocalPlayer.Character:FindFirstChild("Red Key") then
						local args = {
							[1] = "CakeScientist",
							[2] = "Check"
						}

						game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
					else
						if game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == true then
							if string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,"Diablo") or string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,"Deandre") or string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,"Urban") then
								if game:GetService("Workspace").Enemies:FindFirstChild("Diablo") or game:GetService("Workspace").Enemies:FindFirstChild("Deandre") or game:GetService("Workspace").Enemies:FindFirstChild("Urban") then
									for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
										if v.Name == "Diablo" or v.Name == "Deandre" or v.Name == "Urban" then
											if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
												repeat wait()
					    					AutoHaki()
                                           EquipWeapon(_G.SelectWeapon)
											PosMon = v.HumanoidRootPart.CFrame
											topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
											v.HumanoidRootPart.CanCollide = false
											v.Humanoid.WalkSpeed = 0
											v.Head.CanCollide = false
											attackGunEnemies(v.Name , 5)
											v.HumanoidRootPart.Size = Vector3.new(70,70,70)
											StartBring = false
											MonFarm = v.Name
											game:GetService'VirtualUser':CaptureController()
											game:GetService'VirtualUser':Button1Down(Vector2.new(1280, 672))
									    	sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
												until _G.Fullykatakuri == false or v.Humanoid.Health <= 0 or not v.Parent or game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") or game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice")
											end
										end
									end
								else
									if game:GetService("ReplicatedStorage"):FindFirstChild("Diablo") then
										topos(game:GetService("ReplicatedStorage"):FindFirstChild("Diablo").HumanoidRootPart.CFrame * CFrame.new(2,20,2))
									elseif game:GetService("ReplicatedStorage"):FindFirstChild("Deandre") then
										topos(game:GetService("ReplicatedStorage"):FindFirstChild("Deandre").HumanoidRootPart.CFrame * CFrame.new(2,20,2))
									elseif game:GetService("ReplicatedStorage"):FindFirstChild("Urban") then
										topos(game:GetService("ReplicatedStorage"):FindFirstChild("Urban").HumanoidRootPart.CFrame * CFrame.new(2,20,2))
									end
								end
							end
						else
							wait(0.5)
							game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EliteHunter")
						end
					end
				end)
			end
		end
	end)

	AutoFarm:Toggle("Auto Start Chocola", false,function(value)
     	_G.FarmChocola = value
    	StopTween(_G.FarmChocola)
       end)

       spawn(function()
        while wait() do
            local Choccola = CFrame.new(87.94276428222656, 73.55451202392578, -12319.46484375)
            if _G.FarmChocola then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Choccola)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Choccola)
                        end
                    else
                        TP1(Choccola)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Chocolate Bar Battler") or game:GetService("Workspace").Enemies:FindFirstChild("Cocoa Warrior") or game:GetService("Workspace").Enemies:FindFirstChild("Sweet Thief") or game:GetService("Workspace").Enemies:FindFirstChild("Candy Rebel") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Chocolate Bar Battler" or v.Name == "Cocoa Warrior" or v.Name == "Sweet Thief" or v.Name == "Candy Rebel" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.FarmChocola or not v.Parent or v.Humanoid.Health <= 0
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Chocolate Bar Battler" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Cocoa Warrior" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Sweet Thief" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Candy Rebel" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

 end

     if World1 then
       _G.SelectBoss = "The Gorilla King"
       AutoFarm:Dropdown("Auto Select Boss",{"The Saw", "The Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral", "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Saber Expert"},{"The Gorilla King"},function(Value)
        _G.SelectBoss = Value
       end)
   	  elseif World2 then
       _G.SelectBoss = "Diamond"
       AutoFarm:Dropdown("Auto Select Boss",{"Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral", "Cursed Captain", "Darkbeard", "Order", "Awakened Ice Admiral", "Tide Keeper"},{"Diamond"},function(Value)
       _G.SelectBoss = Value
      end)
     elseif World3 then
       _G.SelectBoss = "Stone"
       AutoFarm:Dropdown("Auto Select Boss",{"Stone", "Island Empress", "Rocket Admiral", "Captain Elephant", "Beautiful Pirate", "rip_indra True Form", "Longma", "Soul Reaper", "Cake Queen", "Cake Prince", "Dough King"
},{"Stone"},function(Value)
        _G.SelectBoss = Value
       end)
    end

       AutoFarm:Seperator("Auto Boss Farm")

    BossSpawn = AutoFarm:Label("Auto Check Boss")

       spawn(function()
    while wait() do
        pcall(function()
            if game:GetService("ReplicatedStorage"):FindFirstChild(_G.SelectBoss) or game:GetService("Workspace").Enemies:FindFirstChild(_G.SelectBoss) then
                BossSpawn:Set("Status :Boss Spawn ✅")
            else
                BossSpawn:Set("Status :Boss Not Spawn ❌")
               end
            end)
          end
       end)

    AutoFarm:Toggle("Auto Farm Boss", false,function(value)
      	_G.AutoBoss = value
       	StopTween(_G.AutoBoss)
       end)

       spawn(function()
        while wait() do
            if _G.AutoBoss then
                pcall(function()
                    if game:GetService("Workspace").Enemies:FindFirstChild(_G.SelectBoss) then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == _G.SelectBoss then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.HumanoidRootPart.Size = Vector3.new(80,80,80)
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoBoss or not v.Parent or v.Humanoid.Health <= 0
                                end
                            end
                        end
                    else
                        if game:GetService("ReplicatedStorage"):FindFirstChild(_G.SelectBoss) then
                            topos(game:GetService("ReplicatedStorage"):FindFirstChild(_G.SelectBoss).HumanoidRootPart.CFrame * CFrame.new(5,10,2))
                        end
                    end
                end)
            end
        end
    end)

      AutoFarm:Seperator("Auto Farm Material")

      if World1 then
      AutoFarm:Dropdown("Select Material",{"Farm Leather + Scrap Metal","Farm Fish Tail","Farm Magma Ore","Farm Angel Wings"},{"Farm Fish Tail"},function(Value)
        _G.SelectMaterial = Value
      end)

         spawn(function()
        while wait() do
            local Leather = CFrame.new(-967.433105, 13.5999937, 4034.24707, -0.258864403, 0, -0.965913713, 0, 1, 0, 0.965913713, 0, -0.258864403)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Leather + Scrap Metal' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Leather)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Leather)
                        end
                    else
                        TP1(Leather)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Pirate") or game:GetService("Workspace").Enemies:FindFirstChild("Brute") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Pirate" or v.Name == "Brute"  then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Leather + Scrap Metal'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Pirate" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Brute" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

   spawn(function()
        while wait() do
            local Fish = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Fish Tail' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Fish)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Fish)
                        end
                    else
                        TP1(Fish)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Fishman Commando") or game:GetService("Workspace").Enemies:FindFirstChild("Fishman Warrior") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Fishman Commando" or v.Name == "Fishman Warrior"  then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Fish Tail'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Fishman Commando" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Fishman Warrior" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

   spawn(function()
        while wait() do
            local Magma = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Magma Ore' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Magma)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Magma)
                        end
                    else
                        TP1(Magma)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Military Soldie") or game:GetService("Workspace").Enemies:FindFirstChild("Military Spy") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Military Soldie" or v.Name == "Military Spy"  then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Magma Ore'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Military Soldier" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Military Spy" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

   spawn(function()
        while wait() do
            local Angel = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Angel Wings' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Angel)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Angel)
                        end
                    else
                        TP1(Angel)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Royal Soldier") or game:GetService("Workspace").Enemies:FindFirstChild("Royal Squad") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Royal Soldier" or v.Name == "Royal Squad"  then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Angel Wings'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Royal Soldier" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Royal Squad" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

end

     if World2 then
      AutoFarm:Dropdown("Select Material",{"Farm Leather + Scrap Metal","Farm Radiactive Material","Farm Magma Ore","Farm Vampire Fang","Farm Mystic Droplet","Farm Ectoplasm",},{"Farm Leather + Scrap Metal"},function(Value)
        _G.SelectMaterial = Value
      end)

    spawn(function()
        while wait() do
            local Leather = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Leather + Scrap Metal' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Leather)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Leather)
                        end
                    else
                        TP1(Leather)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Mercenary") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Mercenary" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Leather + Scrap Metal'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Mercenary" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

    spawn(function()
        while wait() do
            local Radiactive = CFrame.new(-105.889565, 72.8076935, -670.247986, -0.965929747, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, -0.965929747)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Radiactive Material' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Radiactive)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Radiactive)
                        end
                    else
                        TP1(Radiactive)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Factory Staff") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Factory Staff" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Radiactive Material'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-105.889565, 72.8076935, -670.247986, -0.965929747, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, -0.965929747))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Factory Staff" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

    spawn(function()
        while wait() do
            local Magma = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Magma Ore' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Magma)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Magma)
                        end
                    else
                        TP1(Magma)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Lava Pirate") or game:GetService("Workspace").Enemies:FindFirstChild("Magma Ninja") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Lava Pirate" or v.Name == "Magma Ninja"  then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Magma Ore'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Lava Pirate" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Magma Ninja" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

    spawn(function()
        while wait() do
            local VampireFang = CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Vampire Fang' then
            pcall(function()
               if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(VampireFang)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(VampireFang)
                        end
                    else
                        TP1(VampireFang)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Vampire") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Vampire" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Vampire Fang'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Vampire" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

    spawn(function()
        while wait() do
            local MysticDroplet = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Mystic Droplet' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(MysticDroplet)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(MysticDroplet)
                        end
                    else
                        TP1(MysticDroplet)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Water Fighter") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Water Fighter" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Mystic Droplet'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Water Fighter" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

   spawn(function()
        while wait() do
            local Ectoplasm = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Ectoplasm' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Ectoplasm.Position).Magnitude > 2000 then
                            BTP(Ectoplasm)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Ectoplasm)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Ectoplasm.Position).Magnitude < 2000 then
                            TP1(Ectoplasm)
                        end
                    else
                        TP1(Ectoplasm)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Ship Deckhand") or game:GetService("Workspace").Enemies:FindFirstChild("Ship Engineer") or game:GetService("Workspace").Enemies:FindFirstChild("Ship Steward") or game:GetService("Workspace").Enemies:FindFirstChild("Ship Officer") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Ship Deckhand" or v.Name == "Ship Engineer" or v.Name == "Ship Steward" or v.Name == "Ship Officer" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Ectoplasm'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Ship Deckhand" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Ship Engineer" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Ship Steward" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Ship Officer" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

end

      if World3 then
      AutoFarm:Dropdown("Select Material",{"Farm Leather + Scrap Metal","Farm Fish Tail","Farm Mini Tusk","Farm Dragon Scale","Farm Conjured Cocoa"},{"Farm Fish Tail"},function(Value)
        _G.SelectMaterial = Value
      end)

      spawn(function()
        while wait() do
            local Leather = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Leather + Scrap Metal' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Leather)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Leather)
                        end
                    else
                        TP1(Leather)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Pirate Millionaire") or game:GetService("Workspace").Enemies:FindFirstChild("Pistol Billionaire") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Pirate Millionaire" or v.Name == "Pistol Billionaire"  then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Leather + Scrap Metal'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Pirate Millionaire" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Pistol Billionaire" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

   spawn(function()
        while wait() do
            local Fish = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Fish Tail' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Fish)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Fish)
                        end
                    else
                        TP1(Fish)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Fishman Raider") or game:GetService("Workspace").Enemies:FindFirstChild("Fishman Captain") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Fishman Raider" or v.Name == "Fishman Captain"  then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Fish Tail'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Fishman Raider" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Fishman Captain" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

   spawn(function()
        while wait() do
            local Mini = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Mini Tusk' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Mini)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Mini)
                        end
                    else
                        TP1(Mini)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Mythological Pirate") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Mythological Pirate" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Mini Tusk'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Mythological Pirate" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

   spawn(function()
        while wait() do
            local Dragon = CFrame.new(6668.76172, 481.376923, 329.12207, -0.121787429, 0, -0.992556155, 0, 1, 0, 0.992556155, 0, -0.121787429)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Dragon Scale' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Dragon)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Dragon)
                        end
                    else
                        TP1(Dragon)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Dragon Crew Archer") or game:GetService("Workspace").Enemies:FindFirstChild("Dragon Crew Warrior") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Dragon Crew Archer" or v.Name == "Dragon Crew Warrior"  then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Dragon Scale'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(6668.76172, 481.376923, 329.12207, -0.121787429, 0, -0.992556155, 0, 1, 0, 0.992556155, 0, -0.121787429))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Dragon Crew Archer" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Dragon Crew Warrior" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

    spawn(function()
        while wait() do
            local Choccola = CFrame.new(87.94276428222656, 73.55451202392578, -12319.46484375)
            if _G.AutoFarmMaterial and _G.SelectMaterial == 'Farm Conjured Cocoa' then
            pcall(function()
                    if BypassTP then
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                            BTP(Choccola)
                            wait(.1)
                            for i = 1, 8 do
                                game.Players.localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Choccola)
			                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                                wait(.1)
                            end
                        elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude < 2000 then
                            TP1(Choccola)
                        end
                    else
                        TP1(Choccola)
                    end
                    if game:GetService("Workspace").Enemies:FindFirstChild("Chocolate Bar Battler") or game:GetService("Workspace").Enemies:FindFirstChild("Cocoa Warrior") or game:GetService("Workspace").Enemies:FindFirstChild("Sweet Thief") or game:GetService("Workspace").Enemies:FindFirstChild("Candy Rebel") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if v.Name == "Chocolate Bar Battler" or v.Name == "Cocoa Warrior" or v.Name == "Sweet Thief" or v.Name == "Candy Rebel" then
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    repeat task.wait()
                                        AutoHaki()
                                        NeedAttacking = true
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        StartBring = true
                                        MonFarm = v.Name
                                        PosMon = v.HumanoidRootPart.CFrame
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                    until not _G.AutoFarmMaterial or not v.Parent or v.Humanoid.Health <= 0 or not _G.SelectMaterial == 'Farm Conjured Cocoa'
                                end
                            end
                        end
                    else
                        StartBring = false
    					topos(CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375))
                        for i,v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                            if v.Name == "Chocolate Bar Battler" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Cocoa Warrior" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Sweet Thief" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            elseif v.Name == "Candy Rebel" then
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(2,20,2))
                            end
                        end
                    end
                end)
            end
        end
    end)

 end

      AutoFarm:Toggle("Auto Farm Material", false,function(Value)
       _G.AutoFarmMaterial = Value
       StopTween(_G.AutoFarmMaterial)
     end)

 ---------------------------- Auto Settings

      KillPercent = "30"
       Settings:Dropdown("Select Healt Mob Farm",{"20","25","30","35","40","45","50","55","60","65","70","75", "80"},{"25"},function(Value)
        KillPercent = Value
      end)

     Settings:Toggle("Auto Use Skill Z",true,function(Z)
       SkillZ = Z
     end)

     Settings:Toggle("Auto Use Skill X",false,function(X)
       SkillX = X
     end)

     Settings:Toggle("Auto Use Skill C",false,function(C)
       SkillC = C
     end)

     Settings:Toggle("Auto Use Skill V",false,function(V)
       SkillV = V
     end)

     Settings:Toggle("Auto Use Skill F",false,function(F)
       SkillF = F
     end)

     Settings:Seperator("Settings Farm")


    Settings:Toggle("Auto Bring Mob", true,function(value)
      _G.BringMonster = value
      _G.BringMob = value
       end)

       spawn(function()
    while task.wait() do
        pcall(function()
            CheckQuest()
            if _G.BringMonster and StartBring and PosMon then
                for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    local isValid = (v.Name == MonFarm or v.Name == Mon)
                    local hasPart = v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head")
                    local isAlive = v.Humanoid and v.Humanoid.Health > 0
                    local inRange = (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 350

                    if isValid and hasPart and isAlive and inRange then
                        local distToPosMon = (v.HumanoidRootPart.Position - PosMon.Position).Magnitude
                        if distToPosMon <= 350 then
                            -- Gôm quái
                            v.HumanoidRootPart.CanCollide = false
                            v.Head.CanCollide = false
                            v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            v.HumanoidRootPart.CFrame = PosMon

                            -- Xoá Animator nếu có
                            if v.Humanoid:FindFirstChild("Animator") then
                                v.Humanoid.Animator:Destroy()
                            end
                        end
                    end
                end

                -- Set SimulationRadius một lần
                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
            end
        end)
    end
end)


spawn(function()
    while wait() do
        pcall(function()
            for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                if _G.BringMob and bringmob then
                    if v.Name == MonFarm and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        if v.Name == "Factory Staff" then
                            if (v.HumanoidRootPart.Position - FarmPos.Position).Magnitude <= 1000000000 then
                                v.Head.CanCollide = false
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.CFrame = FarmPos
                                if v.Humanoid:FindFirstChild("Animator") then
                                    v.Humanoid.Animator:Destroy()
                                end
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                            end
                        elseif v.Name == MonFarm then
                            if (v.HumanoidRootPart.Position - FarmPos.Position).Magnitude <= 10000000000 then
                                v.HumanoidRootPart.CFrame = FarmPos
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                if v.Humanoid:FindFirstChild("Animator") then
                                    v.Humanoid.Animator:Destroy()
                                end
                                v.HumanoidRootPart.CanCollide = false
                                v.Head.CanCollide = false
                                v.Humanoid:ChangeState(11)
                                v.Humanoid:ChangeState(14)
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

if not syn then isnetworkowner = function() return true end end
getgenv().BringMobs = function(F, z)
    PosMon = F
    NameMon = z
end

task.spawn(function()
    while task.wait() do
        pcall(function()
            if PosMon then
                CheckQuest()
                for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if syn then
                        if v.Name == NameMon and v.Name ~= "Ice Admiral" and v.Name ~= "Don Swan" and v.Name ~= "Saber Expert" and v.Name ~= "Longma" and  v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                            if isnetworkowner(v.HumanoidRootPart) then
                                v.HumanoidRootPart.CFrame = PosMon
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(2,2,2)
                                if v.Humanoid:FindFirstChild("Animator") then
                                    v.Humanoid.Animator:Destroy()
                                end
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  math.huge)
                                v.Humanoid:ChangeState(11)
                            end
                        end
                    else
                        if v.Name == NameMon and v.Name ~= "Ice Admiral" and v.Name ~= "Don Swan" and v.Name ~= "Saber Expert" and v.Name ~= "Longma" and  v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                            v.HumanoidRootPart.CFrame = PosMon
                            v.Humanoid.JumpPower = 0
                            v.Humanoid.WalkSpeed = 0
                            v.HumanoidRootPart.CanCollide = false
                            v.HumanoidRootPart.Size = Vector3.new(2,2,2)
                            if v.Humanoid:FindFirstChild("Animator") then
                                v.Humanoid.Animator:Destroy()
                            end
                            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  math.huge)
                            v.Humanoid:ChangeState(11)
                        end
                    end
                end
            end
        end)
    end
end)
PosY = 35

  Settings:Toggle("Auto Walk Water", true,function(value)
      _G.WalkWater = value
 end)

    spawn(function()
			while task.wait() do
				pcall(function()
					if _G.WalkWater then
						game:GetService("Workspace").Map["WaterBase-Plane"].Size = Vector3.new(1000,112,1000)
					else
						game:GetService("Workspace").Map["WaterBase-Plane"].Size = Vector3.new(1000,80,1000)
					end
				end)
			end
        end)

      Settings:Toggle("Auto Set Home Point", false,function(value)
      _G.CheckPoint = value
     end)
    spawn(function()
	    	while task.wait(5) do
	   	    if _G.CheckPoint then
			    pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                end)
		    end
        end
    end)

  Settings:Toggle("Auto Haki Buso", true,function(value)
      _G.AutoHaki = value
     end)
     spawn(function()
    while task.wait(0.1) do
        if _G.AutoHaki then
            pcall(AutoHaki)
        end
    end
end)

     Settings:Toggle("Auto Active Race V3", false,function(value)
      _G.AutoRaceV3 = value
    end)
  spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoRaceV3 then
                game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("ActivateAbility");
             end
          end);
       end
   end)

   Settings:Toggle("Auto Active Race V4", false,function(value)
      _G.AutoRaceV4 = value
    end)
    spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoRaceV4 then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "Y", false, game);
                wait();
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "Y", false, game);
            end
        end);
    end
end)

  Settings:Toggle("Infinite Soru", false,function(Soru)
      InfiniteSoru = Soru
     end)

    spawn(function()
    while task.wait(1) do
        if InfiniteSoru and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil  then
            pcall(function()
                for i,v in next, getgc() do
                    if getfenv(v).script == game.Players.LocalPlayer.Character:WaitForChild("Soru") then
                        for i2,v2 in pairs(debug.getupvalues(v)) do
                            if type(v2) == 'table' then
                                if v2.LastUse then
                                    repeat task.wait(.1)
                                        setupvalue(v, i2, {LastAfter = 0,LastUse = 0})
                                    until not InfiniteSoru or game:GetService("Players").LocalPlayer.Character.Humanoid.Health <= 0
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

    Settings:Toggle("Spin Position", false,function(value)
      _G.SpinPos = value
     end)

PosY = 35
  Settings:Dropdown("Farm Distnace",{"20","25","30","35","40","45","50","55","60","65","70","75","80"},{"50"},function(Value)
        PosY = tonumber(Value) or 50
      end)

  Settings:Toggle("Dodge No CD", false,function(value)
      DodgewithoutCool = value
     end)
     function NoCooldown()
    for i,v in next, getgc() do
        if typeof(v) == "function" then
            if getfenv(v).script == game.Players.LocalPlayer.Character:WaitForChild("Dodge") then
                for i2,v2 in next, getupvalues(v) do
                    if tostring(v2) == "0.4" then
                        setupvalue(v,i2,0)
                      end
                   end
               end
           end
       end
   end
    spawn(function()
       while wait() do
           if DodgewithoutCool then
             pcall(function()
                 NoCooldown()
               end)
            end
       end
    end)

     Settings:Toggle("Infinite Geppo", false,function(Geppo)
         InfiniteGeppo = Geppo
        end)
        spawn(function()
    while task.wait(1) do
        if InfiniteGeppo then
            pcall(function()
                for i,v in next, getgc() do
                    if getfenv(v).script == game.Players.LocalPlayer.Character:WaitForChild("Geppo") then
                        for i2,v2 in next, getupvalues(v) do
                            if tostring(v2) == "0" then
                                repeat wait(.1)
                                    setupvalue(v,i2,0)
                                until not InfiniteGeppo or game:GetService("Players").LocalPlayer.Character.Humanoid.Health <= 0
                            end
                        end
                    end
                end
            end)
        end
    end
end)

    Settings:Toggle("Infinite Jump", false,function(Cokka)
     Infinite = Cokka
 	 game:GetService("UserInputService").JumpRequest:connect(function()
     if Infinite then
     game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
     end
    end)
  end)
