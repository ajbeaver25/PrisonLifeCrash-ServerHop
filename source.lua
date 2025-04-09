local Camera = game:GetService("Workspace").CurrentCamera
local Rstorage = game:GetService("ReplicatedStorage")
local Rservice = game:GetService("RunService")
local Hbeat = Rservice.Heartbeat
local Rstep = Rservice.RenderStepped
local Stepped = Rservice.Stepped
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer
local RegModule = nil
local SavedPositions = {};
local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

task.wait(1)

game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)

-- AntiCrash
LocalPlayer.PlayerScripts:WaitForChild("ClientGunReplicator").Enabled = false

-- Auto Attach on Server hop
queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

Players.LocalPlayer.OnTeleport:Connect(function(State)
	queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/ajbeaver25/PrisonLifeCrash-ServerHop/refs/heads/main/source.lua'))()")
end)

local SaveCamPos = function()
	SavedPositions.OldCameraPos = Camera.CFrame
end

local LoadCamPos = function()
	Rstep:Wait()
	Camera.CFrame = SavedPositions.OldCameraPos or Camera.CFrame
end

local waitfor = function(source, args, interval)
	local int = interval or 5
	local timeout = tick() + int
	repeat Stepped:Wait() until source:FindFirstChild(args) or tick() - timeout >=0
	timeout = nil
	if source:FindFirstChild(args) then
		return source:FindFirstChild(args)
	else
		return nil
	end
end

local TeamEve = function(args)
	workspace.Remote.TeamEvent:FireServer(args)
end

local TeamTo = function(args)
	local tempos = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame; SavedPositions.AutoRe = tempos; SaveCamPos()
	if args == "criminal" then
		if LocalPlayer.TeamColor.Name == "Medium stone grey" then
			TeamEve("Bright orange")
		end
		workspace["Criminals Spawn"].SpawnLocation.CanCollide = false
		repeat
			pcall(function()
				workspace["Criminals Spawn"].SpawnLocation.CFrame = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame
			end)
			Stepped:Wait()
		until LocalPlayer.TeamColor == BrickColor.new("Really red")
		workspace['Criminals Spawn'].SpawnLocation.CFrame = SavedPositions.Crimpad
		return
	elseif args == "inmate" then
		TeamEve("Bright orange")
	elseif args == "guard" then
		TeamEve("Bright blue")
		if #Teams.Guards:GetPlayers() > 7 then
			return
		end
	end
	LocalPlayer.CharacterAdded:Wait(); waitfor(LocalPlayer.Character, "HumanoidRootPart", 5).CFrame = tempos; LoadCamPos()
end

local LocTP = function(cframe)
	LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = cframe
end

local LAction = function(args, args2)
	if args == "sit" then
		LocalPlayer.Character:FindFirstChild("Humanoid").Sit = true
	elseif args == "unsit" then
		if args2 then
			local human = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			for i = 1, 8 do Hbeat:Wait();human.Sit=false;Rstep:Wait();human.Sit=false;Stepped:Wait();human.Sit=false end
		end;LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Running)
	elseif args == "speed" then
		LocalPlayer.Character:FindFirstChild("Humanoid").WalkSpeed = args2
	elseif args == "jumppw" then
		LocalPlayer.Character:FindFirstChild("Humanoid").JumpPower = args2
	elseif args == "die" then
		LocalPlayer.Character:FindFirstChild("Humanoid").Health = 0
	elseif args == "died" then
		LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
	elseif args == "jump" then
		LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	elseif args == "state" then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(args2)
	elseif args == "equip" then
		LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(args2)
	elseif args == "unequip" then
		LocalPlayer.Character:FindFirstChild("Humanoid"):UnequipTools()
	end
end

local RTPing = function(value)
	if value then
		task.wait(value)
	end
	local RT1 = tick()
	pcall(function()
		workspace.Remote.ItemHandler:InvokeServer(workspace.Prison_ITEMS.buttons["Car Spawner"]["Car Spawner"])
	end)
	local RT2 = tick()
	local RoundTrip = (RT2-RT1) * 1000
	return RoundTrip
end

local ItemGrab = function(source, args)
	local lroot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); local timeout = tick() + 5
	if lroot then SavedPositions.GetGunOldPos = not SavedPositions.GetGunOldPos and lroot.CFrame or SavedPositions.GetGunOldPos; end
	local DaItem = source:FindFirstChild(args); local ItemPickup = DaItem.ITEMPICKUP; local IPickup = ItemPickup.Position
	if lroot then LocTP(CFrame.new(IPickup)); end; repeat task.wait()
		pcall(function()
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Sit = false; LocTP(CFrame.new(IPickup))
		end); task.spawn(function()
			game:GetService("Workspace").Remote.ItemHandler:InvokeServer(ItemPickup)
		end)
	until LocalPlayer.Backpack:FindFirstChild(args) or LocalPlayer.Character:FindFirstChild(args) or tick() - timeout >=0
	pcall(function() LocTP(SavedPositions.GetGunOldPos); end); SavedPositions.GetGunOldPos = nil
end

local ItemHand = function(source, args)
	if source and source == "old" then
		game:GetService("Workspace").Remote.ItemHandler:InvokeServer(args)
		return
	end; if false then
		if source then
			ItemGrab(source, args)
		else
			for _,sources in pairs(workspace.Prison_ITEMS:GetChildren()) do
				if sources:FindFirstChild(args) then
					ItemGrab(source, args)
					break
				end
			end
		end
		return
	end; if source then
		workspace.Remote.ItemHandler:InvokeServer({Position = LocalPlayer.Character.Head.Position, Parent = source:FindFirstChild(args)})
	else
		workspace.Remote.ItemHandler:InvokeServer({Position = LocalPlayer.Character.Head.Position, Parent = workspace.Prison_ITEMS.giver:FindFirstChild(args) or workspace.Prison_ITEMS.single:FindFirstChild(args)})
	end
end

local Gun = function(args) 
	if false then
		ItemHand(workspace["Prison_ITEMS"].giver, args)
		return
	end; workspace.Remote.ItemHandler:InvokeServer({Position = LocalPlayer.Character.Head.Position, Parent = workspace.Prison_ITEMS.giver:FindFirstChild(args) or workspace.Prison_ITEMS.single:FindFirstChild(args)})
end

task.spawn(function()
	local america = {}
	for i,v in pairs(Players:GetPlayers()) do
		if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			america[#america+1] = {
				Hit = v.Character:FindFirstChildWhichIsA("BasePart");
				Cframe = v.Character.HumanoidRootPart.CFrame;
				Distance = math.huge;
				RayObject = Ray.new(Vector3.new(), Vector3.new())
			}
		end
	end

    print(#america)

    while task.wait(.3) do
        pcall(function()
            local new = LocalPlayer.Backpack:FindFirstChild("Remington 870") or LocalPlayer.Character:FindFirstChild("Remington 870")
            if not new then
                Gun("Remington 870")
                new = LocalPlayer.Backpack:FindFirstChild("Remington 870")
            end
            for i = 1, 350 do
                Rstorage.ShootEvent:FireServer(america, new)
            end
            task.wait(0.5)
        end)
    end
end)

print("waiting")
if #game.Players:GetPlayers() >= 12 then
	task.wait(80)
end	

warn("SERVER HOPPING")
while true do
    local s,f = pcall(function()
        local found, get = {}, HttpRequest
        local data = get({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", game.PlaceId)})
        local decode = game:GetService("HttpService"):JSONDecode(data.Body)
        if decode and decode.data then
            for i,v in pairs(decode.data) do
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(found, 1, v.id)
                end
            end
        end;if next(found) then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, found[math.random(1, #found)], LocalPlayer)
        end
    end);

    task.wait(8)
end
