ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local status = true
local enableAcVote = 0

local allPlayers = {}
local antiCheatRunning = true
local banlist = {}
function sendToDiscord(message)
  PerformHttpRequest(Config[i].discordLog.webHook, function(err, text, headers) end, 'POST', json.encode({username = 'ANTI-CHEAT', content = message}), { ['Content-Type'] = 'application/json' })
end
ESX.RegisterServerCallback('esx_bagtAnticheat:GetAntiCheatStatus', function(source, cb)	
	local xPlayer = ESX.GetPlayerFromId(source)
	local group = xPlayer.getGroup()
	if group ~= 'user' and Config.adminBypass then
		cb(false)
	else
		cb(status)
	end
end)

RegisterServerEvent("esx_bagtAnticheat:antiCheatIsRunning")
AddEventHandler("esx_bagtAnticheat:antiCheatIsRunning", function()
	antiCheatRunning = true
end)
AddEventHandler('onMySQLReady', function()
	MySQL.Async.fetchAll(
		'SELECT * FROM `banlist`',
		{
		},
		function(result)
			banlist = result
		end
	)
end)

function advertAdmin(message)
	for i = 1 , #allPlayers do
		local xPlayer = ESX.GetPlayerFromId(allPlayers[i])
		local group = xPlayer.getGroup()
		if group ~= user then
			TriggerClientEvent('esx:showNotification', xPlayer.source, message)
		end
	end
end
function ban(xPlayer,reason)
	local ip = GetPlayerEP(xPlayer.source)
	print(ip)
	MySQL.Async.execute(
		'INSERT INTO `banlist` (`identifier`, `reason`, `ip`) VALUES (@identifier, @reason,@ip)',
		{
			['@identifier'] = xPlayer.identifier,
			['@reason']     = reason,
			['@ip'] = ip

		}, function(rowsChanged)	
			table.insert(banlist,{identifier = xPlayer.identifier,reason = reason,ip = ip})	
			if Config[1].action == 2 then
				xPlayer.kick(reason)	
			end
		end
	)
end
AddEventHandler( "playerConnecting", function(name, setReason )
	local identifier = GetPlayerIdentifiers(source)[1]
	local ip = GetPlayerEP(source)
	print(ip)
	for i=1, #banlist do
		if banlist[i].identifier == identifier or banlist[i].ip == ip then
			setReason('you are banned reason :'..banlist[i].reason)
			CancelEvent()
			break
		elseif identifier == nil then
			setReason("Steam is required")
			CancelEvent()
		end
	end
	if Config[1].scanVpn then
		for i = 1 ,#Config[1].blackListIp do
			if Config[1].blackListIp[i].ip == ip then
				setReason('VPN is not allowed on this server')
				CancelEvent()
			end
		end
	end
end)
Citizen.CreateThread(function()
	while Config[1].scanAcEnable do
		Wait(1000)
		if status then
			allPlayers = ESX.GetPlayers()
			for i = 1, #allPlayers do
				--print('checkIfAntiCheatClientIsRunnig')
				local xPlayer = ESX.GetPlayerFromId(allPlayers[i])
				antiCheatRunning = false
				TriggerClientEvent('checkAntiCheatRunning',xPlayer.source)
				for y=1,10 do
		 			Citizen.Wait(1000)
		 			if antiCheatRunning then
		 				break
		 			end
				end
				if not antiCheatRunning then
					if Config[1].txtLogs then
						txtLogs(xPlayer.identifier,' AntiCheat Client Is Not Running probably disable by the player or scripting error The player is only kicked')
					end 
					if Config[1].discordLogs.use then
						sendToDiscord(xPlayer.identifier..' AntiCheat Client Is Not Running probably disable by the player or scripting error The player is only kicked')
					end
					if Config[1].advertAdmin then
						advertAdmin(xPlayer.identifier..' AntiCheat Client Is Not Running probably disable by the player or scripting error The player is only kicked')
					end
					xPlayer.kick('AntiCheat Client Is Not Running')
				end
			end
		end
	end
end)



AddEventHandler("chatMessage",function(Source,Name,Msg)
	if Msg:sub(1,6) == "/runAC" then
		local _source = Source
		local xPlayer = ESX.GetPlayerFromId(_source)
		local time = os.time()
		if xPlayer.getGroup() ~= 'user' then
			print('Starting antiCheat request [ '..time..' ]')
			status = true
			TriggerClientEvent('esx_bagtAnticheat:updateStatus',-1,status)
			if Config[1].txtLogs then
				txtLogs(xPlayer.identifier,' Starting antiCheat request [ '..time..' ]')
			end
			if Config[1].discordLogs.use then
				sendToDiscord(' Starting antiCheat request [ '..time..' ]')
			end
			TriggerEvent('esx_bagtAnticheat:StartCheck')
		end
	elseif Msg:sub(1,12) == "/stopAC" then
		if xPlayer.getGroup() ~= 'user' then
			status = false
			print('stop antiCheat request ')
			TriggerClientEvent('esx_bagtAnticheat:updateStatus',-1,status)
			enableAcVote = 0
			if Config[1].txtLogs then
				txtLogs(xPlayer.identifier,'stop antiCheat request [ '..time..' ]')
			end
			if Config[1].discordLogs.use then
				sendToDiscord(xPlayer.identifier..' stop antiCheat request  [ '..time..' ]')
			end
		end
	end
end)

RegisterServerEvent("esx_bagtAnticheat:flagPlayer")
AddEventHandler("esx_bagtAnticheat:flagPlayer", function(reason)
	local reason = reason
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config[1].action == 1 or Config[1].action == 3 then
		ban(xPlayer,reason)

	elseif Config[1].action == 2 then
		xPlayer.kick(reason)
	end
	if Config[1].discordLogs.use then
		local time = os.date()
		sendToDiscord(GetPlayerName(source..': '..Config.discordLogs.webWook,reason..' ['..time..'] '))
	end
	if Config[1].txtLogs then
		txtLogs(reason,xPlayer.identifier)
	end
end)
function txtLogs(reason,identifier)
	file = io.open( "antiCheatLogs.txt", "a")
	local time = os.date()
	local logs = identifier..': '..reason..' ['..time..'] '
    if file then
        file:write(logs)
        file:write("\n")
    end
    file:close()
end