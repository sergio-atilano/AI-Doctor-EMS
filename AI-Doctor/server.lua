Config = {}
Config.ReviveReward = 100
Config.CopsOnline = 1

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()

	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'ambulance' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1000, CountCops)
end

CountCops()


RegisterServerEvent('AI-Doctor:revive')
AddEventHandler('AI-Doctor:revive', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerMoney = 0
    local societyAccount
    playerMoney = xPlayer.getAccount('bank').money

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_ambulance',function(account)
        societyAccount = account
    end)

    if societyAccount  then
        local societyMoney
        if CopsConnected < Config.CopsOnline then
            if playerMoney >= Config.ReviveReward then
                xPlayer.removeAccountMoney('bank', Config.ReviveReward)
                societyAccount.addMoney(Config.ReviveReward)
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'Pagaste 100€ pela assistência médica.' })
                TriggerClientEvent('doctor:revive', source)
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Lamentamos mas como não tens dinheiro para pagar, não vamos ao local' })
            end
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Não podemos ir ao local, porque há médicos de serviço!'})
        end
    end

end)


TriggerEvent('es:addCommand', 'medico', function(source)
    TriggerEvent('AI-Doctor:revive', source)
    end)