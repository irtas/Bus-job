						--[[
							##################
							#    Irtas		 #
							#	 Momaki		 #
							#    Sun V Rp    #
							#    bus.lua     #
							#      2017      #
							##################
						--]]



-- ped = ig_trafficwarden, 0x5719786d, GetHashkey("ig_trafficwarden")
-- bus = bus, -713569950, 0xD577C962, GetHashkey("bus")
local jobId = -1 -- Don't edit !!!
local isInServicebus = false -- Don't edit !!!
local caution = false -- Don't edit !!!
local cautionprice = 0 -- Caution Price for service car
local busmodel = GetHashKey('taxi') -- Service Car
local busPlate = "CITYBUS" -- Service Car Plate
local busjob = 15 -- bus id job
local emplacement = {
{name="Entreprise Bus",id=56, colour=3, x=463.358, y=-641.092, 27.958},
}

---- THREADS ----

-- Service
Citizen.CreateThread(
	function()
		local x = 453.16
		local y = -636.60
		local z = 28.50

		while true do
			Citizen.Wait(1)
			local playerPos = GetEntityCoords(GetPlayerPed(-1), true)
			if (Vdist(playerPos.x, playerPos.y, playerPos.z, x, y, z) < 100.0) then
				DrawMarker(0, x, y, z - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 0.5001, 211, 207, 123,130, 0, 0, 0,0)
				if (Vdist(playerPos.x, playerPos.y, playerPos.z, x, y, z) < 2.0) then
					if isInServicebus then
						DisplayHelpText('Appuyez sur F6 pour ~r~stopper~s~ votre ~b~service') 
					else
						DisplayHelpText('Appuyez sur F6 pour ~g~prendre~s~ votre ~b~service')
					end
					if (IsControlJustReleased(1, 167)) then 
						TriggerServerEvent('bus:sv_getJobId')						
					end
				end
			end
		end
end)


-- Service Car
Citizen.CreateThread(
	function()
		local x = 465.903
		local y = -606.97
		local z = 28.4993
		while true do
			Citizen.Wait(0)
			local playerPos = GetEntityCoords(GetPlayerPed(-1), true)
			if (Vdist(playerPos.x, playerPos.y, playerPos.z, x, y, z) < 100.0) and isInServicebus then
				DrawMarker(1, x, y, z - 1, 0, 0, 0, 0, 0, 0, 3.0001, 3.0001, 1.5001, 255, 165, 0,165, 0, 0, 0,0)
				if (Vdist(playerPos.x, playerPos.y, playerPos.z, x, y, z) < 4.0) then
					local ply = GetPlayerPed(-1)
				if IsPedInAnyVehicle(ply, true) then
				    DisplayHelpText('Appuyez sur F6 pour ~r~ranger~s~ votre ~b~taxi')
					if (IsControlJustReleased(1, 167)) then 
						local vehicle = GetVehiclePedIsIn(ply, true)
	                    local isVehiclebus = IsVehicleModel(vehicle, busmodel)
						local isbusPlate = GetVehicleNumberPlateText(vehicle)
						Citizen.Trace (isbusPlate)
						Citizen.Trace (busPlate)
                     if isVehiclebus then
					 if isbusPlate == busPlate then
						Deletebus()
						caution = false
						TriggerServerEvent("bus:cautionOff", cautionprice)
						Notify("Vous avez récupérer vos ~g~"..cautionprice.."$~s~ de caution pour le ~b~bus")
					 else
					 Notify("~r~Ce n'est pas un bus de l'entreprise !")
					 end
					 else
					 Notify("~r~Ce n'est pas un bus !")
					 end
					end
				else						
					DisplayHelpText('Appuyez sur F6 pour ~b~sortir~s~ un ~b~bus')
					if (IsControlJustReleased(1, 167)) then 
						Bus()
						caution = true
						TriggerServerEvent("bus:cautionOn", cautionprice)
						Notify("Vous avez laisser ~g~"..cautionprice.."$~s~ de caution pour le ~b~bus")
					end
				end
				end
			end
		end
end)




---- FONCTIONS ----

function Notify(text)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

---------------------------

function Bus()
	Citizen.Wait(0)
	local ped = GetPlayerPed(-1)
	local player = PlayerId()
	local vehicle = busmodel

	RequestModel(vehicle)

	while not HasModelLoaded(vehicle) do
		Wait(1)
	end

	--local plate = math.random(300, 900)
	local coords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0, 5.0, 0)
	local spawned_car = CreateVehicle(vehicle, coords, 465.903, -606.97, 28.4993, -50.32, true, false)
	SetVehicleOnGroundProperly(spawned_car)
	SetVehicleNumberPlateText(spawned_car, busPlate)
	--SetVehicleColours(spawned_car, 12, 131)
	--SetVehicleExtraColours(spawned_car, 12, 12)
	SetPedIntoVehicle(ped, spawned_car, - 1)
	SetModelAsNoLongerNeeded(vehicle)
	Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
end

function Deletebus()
    local ply = GetPlayerPed(-1)
    local playerVeh = GetVehiclePedIsIn(ply, false)
    Citizen.Wait(1)
    ClearPedTasksImmediately(ply)
    SetEntityVisible(playerVeh, false, 0)
    SetEntityCoords(playerVeh, 999999.0, 999999.0, 999999.0, false, false, false, true)
    FreezeEntityPosition(playerVeh, true)
    SetEntityAsMissionEntity(playerVeh, 1, 1)
    DeleteVehicle(playerVeh)
end

-------
---------



RegisterNetEvent('bus:cl_setJobId')
AddEventHandler('bus:cl_setJobId',
	function(p_jobId)
		jobId = p_jobId
		GetService()
	end
)


function GetService()
if jobId ~= busjob then
 Notify("~y~Tu n'est pas chauffeur de bus !") 
		return
end
	if isInServicebus then
		Notify("Vous avez ~r~fini~s~ votre service") 
		if (useModelMenu == true) then
		--TriggerServerEvent("mm:spawn2") 
		end
		TriggerServerEvent('bus:sv_setService', 0) 
		if (useVdkCall == true) then
		TriggerServerEvent("player:serviceOff", "taxi") 
		end
	else 
		Notify("~g~Vous êtes en service !") 
		TriggerServerEvent('bus:sv_setService', 1) 
		if (useVdkCall == true) then
		TriggerServerEvent("player:serviceOn", "taxi") 
		end
	end
	
	isInServicebus = not isInServicebus
-- Here for any clothes with SetPedComponentVariation ... 
end


----------------------------------------------------

-- Copy/paste from fs_freeroam (by FiveM-Script : https://forum.fivem.net/t/alpha-fs-freeroam-0-1-4-fivem-scripts/14097)
RegisterNetEvent("bus:notify")
AddEventHandler("bus:notify", function(icon, type, sender, title, text)
    Citizen.CreateThread(function()
		Wait(1)
		SetNotificationTextEntry("STRING");
		AddTextComponentString(text);
		SetNotificationMessage(icon, icon, true, type, sender, title, text);
		DrawNotification(false, true);
    end)
end)

-- Show blip
Citizen.CreateThread(function()
    for _, item in pairs(emplacement) do
      item.blip = AddBlipForCoord(item.x, item.y, item.z)
      SetBlipSprite(item.blip, item.id)
      SetBlipColour(item.blip, item.colour)
      SetBlipAsShortRange(item.blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(item.name)
      EndTextCommandSetBlipName(item.blip)
    end
end)

-------------



--[[
onJob = 0
local player = GetPlayerPed(-1)

local blip = {
  {name="Bus station", colour=15, id=416, x=-463.358, y=-641.092, z=27.958},
}


-- Creating bus and peds spawn
local bus = {
    {hash= 0xD577C962, x= 463.358, y= -641.627, z= 27.958, a=28.954}
    
    }

local ped = {
   {type=4, hash= 0x5719786d, x= 458.246, y= -637.092, z= 27.958, a= 46.395}
    }

-- function to check if player is in bus
function IsInBus()
  local ply = GetPlayerPed(-1)
  local plyCoords = GetEntityCoords(ply, 0)
  for _, item in pairs(changeYourJob) do
    local distance = GetDistanceBetweenCoords(item.x, item.y, item.z,  plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
    if(distance <= 10) then
      return true
    end
  end
end


-- Loading at map start
AddEventHandler('onClientMapStart', function()


-- Making Bus & peds spawn
RequestModel(0xD577C962) -- Bus
while not HadModelLoaded(0xD577C962) do
   Wait(1)
end
    
RequestModel(0x5719786d) -- Ped
while not HadModelLoaded(0x5719786d) do
   Wait(1)
end
         
-- Spawning the BUS     
         
for _, item in pairs(bus) do
	buses =  CreateVehicle(item.hash, item.x, item.y, item.z, item.a, false, false)
	SetVehicleOnGroundProperly(buses)
end
         
         

-- Spawning the PEDS and giving them weapons and 'relationship'
         
for _, item in pairs(ped) do
	peds = CreatePed(item.type, item.hash, item.x, item.y, item.z, item.a, false, true)
	GiveWeaponToPed(peds, 0x99B507EA, 2800, false, true) -- knives
	SetPedCombatAttributes(peds, 46, true)
	SetPedFleeAttributes(peds, 0, 0)
	SetPedArmour(peds, 100)
	SetPedMaxHealth(peds, 100)
	SetPedRelationshipGroupHash(peds, GetHashKey("CIVMALE"))
	TaskStartScenarioInPlace(peds, "WORLD_HUMAN_GUARD_STAND_PATROL", 0, true)
	SetPedCanRagdoll(peds, false)
	SetPedDiesWhenInjured(peds, false)
	end     
         

-- vehicle_generator bus { -405.24, -650.09, 28.18, heading = 28.53 } // Is it better?

			
-- Bus station blip
Citizen.CreateThread(function()
    for _, item in pairs(blip) do
      item.blip = AddBlipForCoord(item.x, item.y, item.z)
      SetBlipSprite(item.blip, item.id)
      SetBlipAsShortRange(item.blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(item.name)
      EndTextCommandSetBlipName(item.blip)
    end
end)

end)


-- JOB PART --

jobs = {peds = {}, flag = {}, blip = {}, cars = {}, coords = {cx={}, cy={}, cz={}}}

function StartJob(jobid)
	if jobid == 6 then -- Bus job ID
		showLoadingPromt("Loading bus mission", 2000, 3)
		jobs.coords.cx[1],jobs.coords.cy[1],jobs.coords.cz[1] = 293.476,-590.163,42.7371 -- Set Bus stops coords
	end	
end

--]]