local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterCommand(""..Config.Command.."", function(source, args)
    local _source = source
	local tablex = {}
    local _source = source
	local xPlayer = RSGCore.Functions.GetPlayer(_source)
	local group = RSGCore.Functions.GetPermission(_source)
    local cid = xPlayer.PlayerData.citizenid
	local officername = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
	local job_access = false
        for k,v in pairs(Config.Jobs) do
    if xPlayer.PlayerData.job.name == v then
		job_access = true
				exports.oxmysql:fetch("SELECT * FROM (SELECT * FROM `mdt_med_reports` ORDER BY `id` DESC LIMIT 6) sub ORDER BY `id` DESC", {}, function(reports)
					for r = 1, #reports do
						reports[r].charges = json.decode(reports[r].charges)
					end
					exports.oxmysql:fetch("SELECT * FROM (SELECT * FROM `mdt_med_warrants` ORDER BY `id` DESC LIMIT 6) sub ORDER BY `id` DESC", {}, function(warrants)
						for w = 1, #warrants do
							warrants[w].charges = json.decode(warrants[w].charges)
						end
						exports.oxmysql:fetch("SELECT * FROM (SELECT * FROM `mdt_med_notes` ORDER BY `id` DESC LIMIT 6) sub ORDER BY `id` DESC", {}, function(note)
							for n = 1, #note do
								note[n].charges = json.decode(note[n].charges)
							end
						TriggerClientEvent('rsg-mdtmedic:toggleVisibilty', _source, reports, warrants, officername, job, jobgrade, note)
					end)
				end)
			end)
            end
        end
        if job_access == false then
            return false
        end
end)

RegisterServerEvent("rsg-mdtmedic:getOffensesAndOfficer")
AddEventHandler("rsg-mdtmedic:getOffensesAndOfficer", function()
	local usource = source
	local xPlayer = RSGCore.Functions.GetPlayer(usource)
	--local officername = (Character.firstname.. " " ..Character.lastname)
	local officername = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname

	local charges = {}
	exports.oxmysql:fetch('SELECT * FROM med_types', {}, function(fines)
		for j = 1, #fines do
			if fines[j].category == 0 or fines[j].category == 1 or fines[j].category == 2 or fines[j].category == 3 then
				table.insert(charges, fines[j])
			end
		end

		TriggerClientEvent("rsg-mdtmedic:returnOffensesAndOfficer", usource, charges, officername)
	end)
end)


RegisterServerEvent("rsg-mdtmedic:performOffenderSearch")
AddEventHandler("rsg-mdtmedic:performOffenderSearch", function(query)
	local usource = source
	local matches = {}
	exports.oxmysql:query("SELECT * FROM `players` WHERE `charinfo` LIKE ?", {string.lower('%'..query..'%')}, function(result) -- % wildcard, needed to search for all alike results

		for index, data in ipairs(result) do
			if data.charinfo then
				local player = json.decode(data.charinfo)
				local metadata = json.decode(data.metadata)
				local core = RSGCore.Functions.GetPlayerByCitizenId(data.citizenid)

				if core then
					player = core['PlayerData']['charinfo']
					metadata = core['PlayerData']['metadata']
				end

				player.id = data.id
				player.metadata = metadata
				player.citizenid = data.citizenid
				table.insert(matches, player)
			end
		end

		TriggerClientEvent("rsg-mdtmedic:returnOffenderSearchResults", usource, matches)
	end)
end)


---------------------------------------------------------------------------------------




RegisterServerEvent("rsg-mdtmedic:getOffenderDetails")
AddEventHandler("rsg-mdtmedic:getOffenderDetails", function(offender)
	local usource = source

	--print(offender.id)

    exports.oxmysql:fetch('SELECT * FROM `user_med_mdt` WHERE `char_id` = ?', {offender.id}, function(result)

		if result[1] then
            offender.notes = result[1].notes
            offender.mugshot_url = result[1].mugshot_url
            offender.bail = result[1].bail
		else
			offender.notes = ""
			offender.mugshot_url = ""
			offender.bail = false
		end

        exports.oxmysql:fetch('SELECT * FROM `user_med_convictions` WHERE `char_id` = ?', {offender.id}, function(convictions)

            if convictions[1] then
                offender.convictions = {}
                for i = 1, #convictions do
                    local conviction = convictions[i]
                    offender.convictions[conviction.offense] = conviction.count
                end
            end

            exports.oxmysql:fetch('SELECT * FROM `mdt_med_warrants` WHERE `char_id` = ?', {offender.id}, function(warrants)

                if warrants[1] then
                    offender.haswarrant = true
                end
			
				TriggerClientEvent("rsg-mdtmedic:returnOffenderDetails", usource, offender)
            end)
        end)
    end)
end)



RegisterServerEvent("rsg-mdtmedic:getOffenderDetailsById")
AddEventHandler("rsg-mdtmedic:getOffenderDetailsById", function(char_id)
    local usource = source
	print(char_id)

    exports.oxmysql:execute('SELECT * FROM `players` WHERE `id` = ?', {char_id}, function(result)

        local offender = result[1]

        if not offender then
            TriggerClientEvent("rsg-mdtmedic:closeModal", usource)
            TriggerClientEvent("rsg-mdtmedic:sendNotification", usource, "This person no longer exists.")
            return
        end
    
        exports.oxmysql:execute('SELECT * FROM `user_med_mdt` WHERE `char_id` = ?', {char_id}, function(result)

			if result[1] then
                offender.notes = result[1].notes
                offender.mugshot_url = result[1].mugshot_url
                offender.bail = result[1].bail
			else
				offender.notes = ""
				offender.mugshot_url = ""
				offender.bail = false
			end

            exports.oxmysql:execute('SELECT * FROM `user_med_convictions` WHERE `char_id` = ?', {char_id}, function(convictions) 

                if convictions[1] then
                    offender.convictions = {}
                    for i = 1, #convictions do
                        local conviction = convictions[i]
                        offender.convictions[conviction.offense] = conviction.count
                    end
                end

                exports.oxmysql:execute('SELECT * FROM `mdt_med_warrants` WHERE `char_id` = ?', {char_id}, function(warrants)
                    
                    if warrants[1] then
                        offender.haswarrant = true
                    end

					TriggerClientEvent("rsg-mdtmedic:returnOffenderDetails", usource, offender)
                end)
            end)
        end)
    end)
end)

RegisterServerEvent("rsg-mdtmedic:saveOffenderChanges")
AddEventHandler("rsg-mdtmedic:saveOffenderChanges", function(id, changes, identifier)
	local usource = source

	exports.oxmysql:fetch('SELECT * FROM `user_med_mdt` WHERE `char_id` = ?', {id}, function(result)
		if result[1] then
			exports.oxmysql:execute('UPDATE `user_med_mdt` SET `notes` = ?, `mugshot_url` = ?, `bail` = ? WHERE `char_id` = ?', {changes.notes, changes.mugshot_url, changes.bail, id})
		else
			exports.oxmysql:insert('INSERT INTO `user_med_mdt` (`char_id`, `notes`, `mugshot_url`, `bail`) VALUES (?, ?, ?, ?)', {id, changes.notes, changes.mugshot_url, changes.bail})
		end

		if changes.convictions ~= nil then
			for conviction, amount in pairs(changes.convictions) do	
				exports.oxmysql:execute('UPDATE `user_med_convictions` SET `count` = ? WHERE `char_id` = ? AND `offense` = ?', {id, amount, conviction})
			end
		end

		for i = 1, #changes.convictions_removed do
			exports.oxmysql:execute('DELETE FROM `user_med_convictions` WHERE `char_id` = ? AND `offense` = ?', {id, changes.convictions_removed[i]})
		end

		TriggerClientEvent("rsg-mdtmedic:sendNotification", usource, Config.Notify['1'])
	end)
end)

RegisterServerEvent("rsg-mdtmedic:saveReportChanges")
AddEventHandler("rsg-mdtmedic:saveReportChanges", function(data)
	exports.oxmysql:execute('UPDATE `mdt_med_reports` SET `title` = ?, `incident` = ? WHERE `id` = ?', {data.id, data.title, data.incident})
	TriggerClientEvent("rsg-mdtmedic:sendNotification", source, Config.Notify['2'])
end)

RegisterServerEvent("rsg-mdtmedic:deleteReport")
AddEventHandler("rsg-mdtmedic:deleteReport", function(id)
	exports.oxmysql:execute('DELETE FROM `mdt_med_reports` WHERE `id` = ?', {id})
	TriggerClientEvent("rsg-mdtmedic:sendNotification", source, Config.Notify['3'])
end)

RegisterServerEvent("rsg-mdtmedic:deleteNote")
AddEventHandler("rsg-mdtmedic:deleteNote", function(id)
	exports.oxmysql:execute('DELETE FROM `mdt_med_notes` WHERE `id` = ?', {id})
	TriggerClientEvent("rsg-mdtmedic:sendNotification", source, Config.Notify['9'])
end)

RegisterServerEvent("rsg-mdtmedic:submitNewReport")
AddEventHandler("rsg-mdtmedic:submitNewReport", function(data)
	local usource = source
	local tablex = {}
    local _source = source
	local xPlayer = RSGCore.Functions.GetPlayer(usource)
	--local cid = xPlayer.PlayerData.citizenid
	local officername = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname

	charges = json.encode(data.charges)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	exports.oxmysql:insert('INSERT INTO `mdt_med_reports` (`char_id`, `title`, `incident`, `charges`, `author`, `name`, `date`) VALUES (?, ?, ?, ?, ?, ?, ?)', {data.char_id, data.title, data.incident, charges, officername, data.name, data.date,}, function(id)
		TriggerEvent("rsg-mdtmedic:getReportDetailsById", id, usource)
		TriggerClientEvent("rsg-mdtmedic:sendNotification", usource, Config.Notify['4'])
	end)

	for offense, count in pairs(data.charges) do
		exports.oxmysql:fetch('SELECT * FROM `user_med_convictions` WHERE `offense` = ? AND `char_id` = ?', {offense, data.char_id}, function(result)
			if result[1] then
				exports.oxmysql:execute('UPDATE `user_med_convictions` SET `count` = ? WHERE `offense` = ? AND `char_id` = ?', {data.char_id, offense, count + 1})
			else
				exports.oxmysql:insert('INSERT INTO `user_med_convictions` (`char_id`, `offense`, `count`) VALUES (?, ?, ?)', {data.char_id, offense, count})
			end
		end)
	end
end)

RegisterServerEvent("rsg-mdtmedic:submitNote")
AddEventHandler("rsg-mdtmedic:submitNote", function(data)
	local usource = source
	local tablex = {}
    local _source = source
	local xPlayer = RSGCore.Functions.GetPlayer(usource)
	--local cid = xPlayer.PlayerData.citizenid
	local officername = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
	charges = json.encode(data.charges)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	exports.oxmysql:insert('INSERT INTO `mdt_med_notes` ( `title`, `incident`, `author`, `date`) VALUES (?, ?, ?, ?)', {data.title, data.note, officername, data.date,}, function(id)
		TriggerEvent("rsg-mdtmedic:getNoteDetailsById", id, usource)
		TriggerClientEvent("rsg-mdtmedic:sendNotification", usource, Config.Notify['8'])
	end)
end)

RegisterServerEvent("rsg-mdtmedic:performReportSearch")
AddEventHandler("rsg-mdtmedic:performReportSearch", function(query)
	local usource = source
	local matches = {}
	exports.oxmysql:fetch("SELECT * FROM `mdt_med_reports` WHERE `id` LIKE @query OR LOWER(`title`) LIKE @query OR LOWER(`name`) LIKE @query OR LOWER(`author`) LIKE @query or LOWER(`charges`) LIKE @query", {
		['@query'] = string.lower('%'..query..'%') -- % wildcard, needed to search for all alike results
	}, function(result)

		for index, data in ipairs(result) do
			data.charges = json.decode(data.charges)
			table.insert(matches, data)
		end

		TriggerClientEvent("rsg-mdtmedic:returnReportSearchResults", usource, matches)
	end)
end)

RegisterServerEvent("rsg-mdtmedic:getWarrants")
AddEventHandler("rsg-mdtmedic:getWarrants", function()
	local usource = source
	exports.oxmysql:fetch("SELECT * FROM `mdt_med_warrants`", {}, function(warrants)
		for i = 1, #warrants do
			warrants[i].expire_time = ""
			warrants[i].charges = json.decode(warrants[i].charges)
		end
		TriggerClientEvent("rsg-mdtmedic:returnWarrants", usource, warrants)
	end)
end)

RegisterServerEvent("rsg-mdtmedic:submitNewWarrant")
AddEventHandler("rsg-mdtmedic:submitNewWarrant", function(data)
	local usource = source
	local tablex = {}
    local _source = source
	local xPlayer = RSGCore.Functions.GetPlayer(usource)
	--local cid = xPlayer.PlayerData.citizenid
	local officername = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname

	data.charges = json.encode(data.charges)
	data.author = officername
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	exports.oxmysql:insert('INSERT INTO `mdt_med_warrants` (`name`, `char_id`, `report_id`, `report_title`, `charges`, `date`, `expire`, `notes`, `author`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {data.name, data.char_id, data.report_id, data.report_title, data.charges, data.date, data.expire, data.notes, data.author}, function()
		TriggerClientEvent("rsg-mdtmedic:completedWarrantAction", usource)
		TriggerClientEvent("rsg-mdtmedic:sendNotification", usource, Config.Notify['5'])
	end)
end)

RegisterServerEvent("rsg-mdtmedic:deleteWarrant")
AddEventHandler("rsg-mdtmedic:deleteWarrant", function(id)
	local usource = source
	exports.oxmysql:execute('DELETE FROM `mdt_med_warrants` WHERE `id` = ?', {id}, function()
		TriggerClientEvent("rsg-mdtmedic:completedWarrantAction", usource)
	end)
	TriggerClientEvent("rsg-mdtmedic:sendNotification", usource, Config.Notify['6'])
end)

RegisterServerEvent("rsg-mdtmedic:getReportDetailsById")
AddEventHandler("rsg-mdtmedic:getReportDetailsById", function(query, _source)
	if _source then source = _source end
	local usource = source
	exports.oxmysql:fetch("SELECT * FROM `mdt_med_reports` WHERE `id` = ?", {query}, function(result)
		if result and result[1] then
			result[1].charges = json.decode(result[1].charges)
			TriggerClientEvent("rsg-mdtmedic:returnReportDetails", usource, result[1])
		else
			TriggerClientEvent("rsg-mdtmedic:closeModal", usource)
			TriggerClientEvent("rsg-mdtmedic:sendNotification", usource, Config.Notify['7'])
		end
	end)
end)

RegisterServerEvent("rsg-mdtmedic:getNoteDetailsById")
AddEventHandler("rsg-mdtmedic:getNoteDetailsById", function(query, _source)
	if _source then source = _source end
	local usource = source
	exports.oxmysql:fetch("SELECT * FROM `mdt_med_notes` WHERE `id` = ?", {query}, function(result)
		if result and result[1] then
			TriggerClientEvent("rsg-mdtmedic:returnNoteDetails", usource, result[1])
		else
			TriggerClientEvent("rsg-mdtmedic:closeModal", usource)
			TriggerClientEvent("rsg-mdtmedic:sendNotification", usource, Config.Notify['8'])
		end
	end)
end)