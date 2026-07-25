CreateThread(function()
	RegisterChatCommands()
	RegisterCallbacks()
	RegisterMiddleware()

	RegisterItems()
end)

function RegisterMiddleware()
	plsr.Middleware:Add("Characters:Spawning", function(source)
		local char = plsr.Fetch:CharacterSource(source)
		if char:GetData("Animations") == nil then
			char:SetData("Animations", { walk = "default", expression = "default", emoteBinds = {} })
		end
	end, 10)
end

function RegisterChatCommands()
	plsr.Chat:RegisterCommand("e", function(source, args, rawCommand)
		local emote = args[1]
		if emote == "c" or emote == "cancel" then
			TriggerClientEvent("Animations:Client:CharacterCancelEmote", source)
		else
			TriggerClientEvent("Animations:Client:CharacterDoAnEmote", source, emote)
		end
	end, {
		help = "Do An Emote or Dance",
		params = { {
			name = "Emote",
			help = "Name of The Emote",
		} },
	})
	plsr.Chat:RegisterCommand("emotes", function(source, args, rawCommand)
		TriggerClientEvent("Execute:Client:Component", source, "Animations", "OpenMainEmoteMenu")
	end, {
		help = "Open Emote Menu",
	})
	plsr.Chat:RegisterCommand("emotebinds", function(source, args, rawCommand)
		TriggerClientEvent("Animations:Client:OpenEmoteBinds", source)
	end, {
		help = "Edit Emote Binds",
	})
	plsr.Chat:RegisterCommand("walks", function(source, args, rawCommand)
		TriggerClientEvent("Execute:Client:Component", source, "Animations", "OpenWalksMenu")
	end, {
		help = "Change Walk Style",
	})
	plsr.Chat:RegisterCommand("face", function(source, args, rawCommand)
		TriggerClientEvent("Execute:Client:Component", source, "Animations", "OpenExpressionsMenu")
	end, {
		help = "Change Facial Expression",
	})
	plsr.Chat:RegisterCommand("selfie", function(source, args, rawCommand)
		local char = plsr.Fetch:CharacterSource(source)
		if
			not plsr.State:Player(source).isCuffed
			and not plsr.State:Player(source).isDead
			and hasValue(char:GetData("States"), "PHONE")
		then
			TriggerClientEvent("Animations:Client:Selfie", source)
		else
			plsr.Execute:Client(source, "Notification", "Error", "You do not have a phone.")
		end
	end, {
		help = "Open Selfie Mode",
	})
end

function RegisterCallbacks()
	plsr.Callbacks:RegisterServerCallback("Animations:UpdatePedFeatures", function(source, data, cb)
		local char = plsr.Fetch:CharacterSource(source)
		if char then
			cb(plsr.Animations.PedFeatures:UpdateFeatureInfo(char, data.type, data.data))
		else
			cb(false)
		end
	end)

	plsr.Callbacks:RegisterServerCallback("Animations:UpdateEmoteBinds", function(source, data, cb)
		local char = plsr.Fetch:CharacterSource(source)
		if char then
			cb(plsr.Animations.EmoteBinds:Update(char, data), data)
		else
			cb(false)
		end
	end)
end

ANIMATIONS = {
	PedFeatures = {
		UpdateFeatureInfo = function(self, char, type, data, cb)
			if type == "walk" then
				local currentData = char:GetData("Animations")
				char:SetData(
					"Animations",
					{ walk = data, expression = currentData.expression, emoteBinds = currentData.emoteBinds }
				)
				return true
			elseif type == "expression" then
				local currentData = char:GetData("Animations")
				char:SetData(
					"Animations",
					{ walk = currentData.walk, expression = data, emoteBinds = currentData.emoteBinds }
				)
				return true
			end
			return false
		end,
	},
	EmoteBinds = {
		Update = function(self, char, data, cb)
			local currentData = char:GetData("Animations")
			char:SetData(
				"Animations",
				{ walk = currentData.walk, expression = currentData.expression, emoteBinds = data }
			)
			return true
		end,
	},
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Animations", ANIMATIONS)
end)

RegisterServerEvent("Animations:Server:ClearAttached", function(propsToDelete)
	local src = source
	local ped = GetPlayerPed(src)

	if ped then
		for k, v in ipairs(GetAllObjects()) do
			if DoesEntityExist(v) and GetEntityAttachedTo(v) == ped and propsToDelete[GetEntityModel(v)] then
				DeleteEntity(v)
			end
		end
	end
end)

local pendingSend = false

RegisterServerEvent("Selfie:CaptureSelfie", function()
	local src = source
	local char = plsr.Fetch:CharacterSource(src)
	if char then
		if pendingSend then
			plsr.Execute:Client(src, "Notification", "Warn", "Please wait while current photo is uploading", 2000)
			return
		end
		pendingSend = true
		plsr.Execute:Client(src, "Notification", "Info", "Prepping Photo Upload", 2000)

		plsr.Callbacks:ClientCallback(src, "Selfie:Client:UploadPhoto", {
			api = tostring(GetConvar("phone_selfie_webhook", "")),
			token = tostring(GetConvar("phone_selfie_token", "")),
		}, function(ret)
			if ret then
				local _data = {
					image_url = json.decode(ret).url,
				}
				local retval = plsr.Photos:Create(src, _data)
				if retval then
					pendingSend = false
					TriggerClientEvent("Selfie:DoCloseSelfie", src)
					plsr.Execute:Client(src, "Notification", "Success", "Photo uploaded successfully!", 2000)
				else
					pendingSend = false
					TriggerClientEvent("Selfie:DoCloseSelfie", src)
					plsr.Execute:Client(src, "Notification", "Error", "Error uploading photo!", 2000)
				end
			else
				pendingSend = false
				TriggerClientEvent("Selfie:DoCloseSelfie", src)
				plsr.Execute:Client(src, "Notification", "Error", "Error uploading photo!", 2000)
				print("^1ERROR: " .. data)
			end
		end)
	end
end)
