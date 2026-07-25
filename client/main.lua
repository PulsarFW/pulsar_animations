GLOBAL_VEH = nil

IsInAnimation = false

_isPointing = false
_isCrouched = false

walkStyle = "default"
facialExpression = "default"
emoteBinds = {}

_doingStateAnimation = false

CreateThread(function()
	plsr.State.flags.sitting = false
	plsr.State.flags.anim = false
	plsr.State.flags.animProp1 = false
	plsr.State.flags.animPtfx = false
	plsr.State.flags.drunkMovement = false

	RegisterKeybinds()

	RegisterChairTargets()

	plsr.Interaction:RegisterMenu("expressions", "Expressions", "face-laugh-squint", function()
		plsr.Interaction:Hide()
		plsr.Animations:OpenExpressionsMenu()
	end)

	plsr.Interaction:RegisterMenu("walks", "Walk Styles", "person-walking", function()
		plsr.Interaction:Hide()
		plsr.Animations:OpenWalksMenu()
	end)

	plsr.Callbacks:RegisterClientCallback("Selfie:Client:UploadPhoto", function(data, cb)
		local options = {
			encoding = "webp",
			quality = 0.8,
			headers = {
				Authorization = string.format("%s", data.token),
			},
		}
		exports["screenshot-basic"]:requestScreenshotUpload(
			string.format("%s", data.api),
			"image",
			options,
			function(data)
				local image = json.decode(data)
				cb(json.encode({ url = image.url }))
			end
		)
	end)
end)

local pauseListener = nil
AddEventHandler("Characters:Client:Spawn", function()
	plsr.Animations.Emotes:Cancel()
	TriggerEvent("Animations:Client:StandUp", true, true)

	pauseListener = plsr.State:Watch('flags', 'inPauseMenu', function(value)
		if
			value
			and not plsr.State.flags.isDead
			and not plsr.State.flags.isCuffed
			and not plsr.State.flags.isHardCuffed
		then
			if not plsr.Animations.Emotes:Get() then
				plsr.Animations.Emotes:Play("map", false, nil, true, true)
			end
		else
			if not value and plsr.Animations.Emotes:Get() == "map" then
				plsr.Animations.Emotes:ForceCancel()
			end
		end
	end)

	CreateThread(function()
		while plsr.State.flags.loggedIn do
			Wait(5000)
			if not _isCrouched and not plsr.State.flags.drunkMovement then
				plsr.Animations.PedFeatures:RequestFeaturesUpdate()
			end
		end
	end)

	CreateThread(function()
		while plsr.State.flags.loggedIn do
			Wait(5)
			DisableControlAction(0, 36, true)
			if IsDisabledControlJustPressed(0, 36) then
				plsr.Animations.PedFeatures:ToggleCrouch()
			end
			if IsInAnimation and IsPedShooting(PlayerPedId()) then
				plsr.Animations.Emotes:ForceCancel()
			end
		end
	end)

	if plsr.State.flags.loggedIn and plsr.State.character.Animations then
		local data = plsr.State.character.Animations
		walkStyle, facialExpression, emoteBinds = data.walk, data.expression, data.emoteBinds
		plsr.Animations.PedFeatures:RequestFeaturesUpdate()
	else
		walkStyle, facialExpression, emoteBinds =
			Config.DefaultSettings.walk, Config.DefaultSettings.expression, Config.DefaultSettings.emoteBinds
		plsr.Animations.PedFeatures:RequestFeaturesUpdate()
	end
end)

RegisterNetEvent("Characters:Client:Logout", function()
	plsr.Animations.Emotes:ForceCancel()
	Wait(20)

	-- plsr.State:Watch has no unsubscribe API (matches the reference State system) - the watcher
	-- stays registered and just no-ops harmlessly if it fires again before the next spawn
	if plsr.State.flags.anim then
		plsr.State:SetPublicClientFlag('anim', false)
	end
end)

RegisterNetEvent("Vehicles:Client:EnterVehicle", function(veh)
	GLOBAL_VEH = veh
end)

RegisterNetEvent("Vehicles:Client:ExitVehicle", function()
	GLOBAL_VEH = nil
end)

function RegisterKeybinds()
	plsr.Keybinds:Add("pointing", "b", "keyboard", "Pointing - Toggle", function()
		if _isPointing then
			StopPointing()
		else
			StartPointing()
		end
	end)

	plsr.Keybinds:Add("ragdoll", Config.RagdollKeybind, "keyboard", "Ragdoll - Toggle", function()
		local time = 3500
		Wait(350)
		ClearPedSecondaryTask(PlayerPedId())
		SetPedToRagdoll(PlayerPedId(), time, time, 0, 0, 0, 0)
	end)

	plsr.Keybinds:Add("emote_cancel", "x", "keyboard", "Emotes - Cancel Current", function()
		plsr.Animations.Emotes:Cancel()

		TriggerEvent("Animations:Client:StandUp")
		TriggerEvent("Animations:Client:Selfie", false)
		TriggerEvent("Animations:Client:UsingCamera", false)
	end)

	-- Don't specify and key so then players can set it themselves if they want to use...
	plsr.Keybinds:Add("emote_menu", "", "keyboard", "Emotes - Open Menu", function()
		plsr.Animations:OpenMainEmoteMenu()
	end)

	-- There are 4 emote binds and by default they use numbers 6, 7, 8 and 9
	for bindNum = 1, 4 do
		plsr.Keybinds:Add(
			"emote_bind_" .. bindNum,
			tostring(5 + bindNum),
			"keyboard",
			"Emotes - Bind #" .. bindNum,
			function()
				plsr.Animations.EmoteBinds:Use(bindNum)
			end
		)
	end
end
