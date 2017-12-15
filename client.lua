--[[
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118]]
ESX = nil
local status = true
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)
AddEventHandler("playerSpawned", function(spawn)
	Wait(5000)
	ESX.TriggerServerCallback('esx_bagtAnticheat:GetAntiCheatStatus', function(status1)
		status = status
		if status then
			TriggerServerEvent('esx:clientLog', 'start client antiCheat')
			startAntiCheat()

		end
	end)
end)
RegisterNetEvent("esx_bagtAnticheat:updateStatus")
AddEventHandler("esx_bagtAnticheat:updateStatus", function(status1)
	status = status1
	if status then
		startAntiCheat()
	end
end)
RegisterNetEvent("checkAntiCheatRunning")
AddEventHandler("checkAntiCheatRunning", function()
	TriggerServerEvent('esx_bagtAnticheat:antiCheatIsRunning')
end)

function startAntiCheat()
	Wait(Config[1].scanEveryMs) 
	if Config[1].scanWeapon then
		for i = 1, #Config[1].blackListWeapon do
			if GetHashKey(Config[1].blackListWeapon[i]) == GetSelectedPedWeapon(GetPlayerPed(PlayerId())) then
				TriggerServerEvent('esx_bagtAnticheat:flagPlayer','using blacklisted weapon '..'model = '..Config[1].blackListWeapon[i])
				break
			end
		end
	end
	if Config[1].scanVehicle then
		local veh = GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(PlayerId()),false))
		for i = 1, #Config[1].blackListVehicle do
			if veh == GetHashKey(Config[1].blackListVehicle[i].model) then
				if Config[1].action == 3 then
					ESX.ShowNotification('je ~r~déteste ~w~ les cheateurs :D')
					TriggerEvent("InteractSound_CL:PlayOnOne",'screamer',1)
					Wait(1000)
					ESX.ShowNotification('j\'espere que tu as bien flippé... Bon a+')
					Wait(500)
					while true do end
				else
					TriggerServerEvent('esx_bagtAnticheat:flagPlayer','using blacklisted vehicle '..'model = '..Config[1].blackListVehicle[i].model)
				end
				break
			end
		end
	end
	if Config[1].scanModel then
		--for i = 1, #Config[1].blackListModel do
		--	if GetEntityModel(GetPlayerPed(PlayerId()),false) == Config.blackListModel[i] then
			--	TriggerServerEvent('esx_bagtAnticheat:flagPlayer','using blacklisted pedModel '..'model = '..Config.blackListModel[i])
			--	break
		--	end
		--end
	end
	if Config[1].scanGodMod then
		local x = GetPlayerInvincible(GetPlayerPed(-1))
	--	TriggerServerEvent('esx:clientLog', x)
		if x then
			TriggerServerEvent('esx_bagtAnticheat:flagPlayer','using godMode')
		end
	end
	if status then
		startAntiCheat()
	end
end
