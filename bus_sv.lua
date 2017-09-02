local busjob = '15'


RegisterServerEvent('bus:sv_setService')
AddEventHandler('bus:sv_setService', function(service)
    TriggerEvent('es:getPlayerFromId', source, function(user)
	local player = user.getIdentifier()
        MySQL.Async.execute("UPDATE users SET enService = @service WHERE users.identifier = @identifier", {['@identifier'] = player, ['@service'] = service})
    end)
end)

RegisterServerEvent('bus:sv_getJobId')
AddEventHandler('bus:sv_getJobId', function()
local source = source
	TriggerEvent('es:getPlayerFromId', source, function(user)
    TriggerClientEvent('bus:cl_setJobId', source, user.getJob())
	end)
end)



RegisterServerEvent('busJob:addMoney')
AddEventHandler('busJob:addMoney', function(amount)
  TriggerEvent('es:getPlayerFromId', source, function(user)
        local nameJob = nameJob(id)
       if nameJob == 6 then -- Bus driver job ID  
    user.addMoney((amount))
	end
     end)
end)
