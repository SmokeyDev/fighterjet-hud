local isInVehicle = false;
local inPlane = false;
local restoreRadar = false;
local stallWarning = false;
local altitudeWarning = false;
local retractableGear = false;
local wasInAir = false;
local wasTargeted = false;
local hasVtol = false;
local currentColor = "green";

Citizen.CreateThread(function()
    DisplayRadar(true);
    while true do
        Citizen.Wait(15);
        if (inPlane) then
            local ped = GetPlayerPed(-1);
            local veh = GetVehiclePedIsIn(ped, false);
            local pos = GetEntityCoords(veh);
            local speed = GetEntitySpeed(veh);
            local altitude = GetEntityHeightAboveGround(veh);
            local rawAlt = altitude;
            local rotation = GetEntityRotation(veh, 2);
            local direction = math.floor(rotation[3]);
			if(direction < 0) then direction = direction*-1 else direction = 360-direction end
			if(direction == 360) then direction = 0 end
            local gear = GetLandingGearState(veh);
            local gearWorks = IsPlaneLandingGearIntact(veh);
            local vtol = 0.0;
            local hasWeapon, weapon = GetCurrentPedVehicleWeapon(ped);
            local weaponType = "none";
            local targetDist = 0;
            local hasLock, target = GetVehicleLockOnTarget(veh);
            local targetPos;
            local visible_target, x_target, y_target;
            local homingRadius = GetOffsetFromEntityInWorldCoords(veh, 0.0, -320.0, 0.0);
            local homingEnd = GetOffsetFromEntityInWorldCoords(veh, 0.0, -10.0, 0.0);
            local incoming = IsProjectileInArea(homingRadius.x, homingRadius.y, homingRadius.z, homingEnd.x, homingEnd.y, homingEnd.z, false);
            
            if (not wasTargeted and incoming) then
                wasTargeted = true;
                SendNUIMessage({
                    action = "missile",
                    mode = "start"
                });
            elseif (wasTargeted and not incoming) then
                wasTargeted = false;
                SendNUIMessage({
                    action = "missile",
                    mode = "end"
                });
            end
            if (hasLock == 1) then
                targetPos = GetEntityCoords(target);
                targetDist = Vdist(pos.x, pos.y, pos.z, targetPos.x, targetPos.y, targetPos.z)
                visible_target, x_target, y_target = World3dToScreen2d(targetPos.x, targetPos.y, targetPos.z);
                if (Config.Altitude == "feet") then
                    targetDist = math.floor(targetDist * 3.2808399);
                else
                    targetDist = math.floor(targetDist);
                end
            else
                targetPos = GetOffsetFromEntityInWorldCoords(veh, 0.0, 150.0, 0.0);
                visible_target, x_target, y_target = World3dToScreen2d(targetPos.x, targetPos.y, targetPos.z);
            end
            if (hasWeapon) then
                for k,v in next, Config.Weapons do
                    if (k == weapon) then
                        weaponType = v;
                    end
                end
            end
            if (hasVtol) then
                vtol = GetPlaneVtolDirection(veh);
            end
            if (Config.StallWarning) then
                if (altitude > 80 and speed < 20.0 and vtol ~= 1.0) then
                    if (not stallWarning) then
                        SendNUIMessage({
                            action = "stall",
                            mode = "start"
                        });
                    end
                    stallWarning = true;
                else
                    if (stallWarning) then
                        SendNUIMessage({
                            action = "stall",
                            mode = "end"
                        });
                    end
                    stallWarning = false;
                end
            end
            if (Config.AltitudeWarning) then
                if (wasInAir) then
                    if (altitude <= 2 and speed < 10.0) then
                        wasInAir = false; 
                    end
                    if (altitude <= Config.AltitudeWarningHeigth and speed > 50.0 and (gear == 4 or gear == 1 or not retractableGear)) then
                        if (not altitudeWarning) then
                            SendNUIMessage({
                                action = "altitude",
                                mode = "start"
                            });
                        end
                        altitudeWarning = true;
                    else
                        if (altitudeWarning) then
                            SendNUIMessage({
                                action = "altitude",
                                mode = "end"
                            });
                        end
                        altitudeWarning = false;
                    end
                elseif (altitude > 100) then
                    wasInAir = true;
                end
            end
            if (Config.Speed == "kilometers") then
                speed = math.floor(speed * 3.6);
            elseif (Config.Speed == "miles") then
                speed = math.floor(speed * 2.236936);
            elseif (Config.Speed == "knots") then
                speed = math.floor(speed * 1.944);
            end
            if (Config.Altitude == "feet") then
                altitude = math.floor(altitude * 3.2808399);
            else
                altitude = math.floor(altitude);
            end
            if (altitude < 0) then
                altitude = 0;
            end
            if (direction < 0) then
                direction = direction + 360;
            end
            if (gear == 0) then
                gear = "DEPLOYED";
            elseif (gear == 1) then
                gear = "RETRACTING";
            elseif (gear == 3) then
                gear = "DEPLOYING";
            elseif (gear == 4) then
                gear = "RETRACTED";
            end
            if (not gearWorks) then
                gear = "MALFUNCTION";
            end
            if (not retractableGear) then
                gear = "STATIC";
            end
            if (vtol == 0.0) then
                vtol = "INACTIVE";
            elseif (vtol == 1.0) then
                vtol = "ACTIVE";
            else
                vtol = "SWITCHING";
            end
            SendNUIMessage({
                action = "update",
                yaw = direction,
                pitch = rotation[1],
                roll = rotation[2],
                speed = speed,
                altitude = altitude,
                rawAlt = rawAlt,
                gear = gear,
                hasVtol = hasVtol,
                vtol = vtol,
                hasLock = hasLock,
                x_target = x_target,
                y_target = y_target,
                targetDist = targetDist,
                hasWeapon = hasWeapon,
                weaponType = weaponType
            });
        end
    end
end);

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1);
        if (inPlane) then
            if (Config.DisableRadar) then
                DisplayRadar(false);
            end
            HideHudComponentThisFrame(14);
            if (Config.OnlyFirstPerson) then
                if (IsControlJustReleased(2, 0)) then
                    Citizen.CreateThread(function()
                        Citizen.Wait(100);
                        if (GetFollowVehicleCamViewMode() == 4) then
                            SendNUIMessage({
                                action = "show",
                                color = currentColor
                            });
                        else
                            SendNUIMessage({
                                action = "hide"
                            });
                        end
                    end);
                end
            end
        end
    end
end);

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(50);
		local ped = GetPlayerPed(-1);
		if (not isInVehicle and not IsPlayerDead(ped)) then
			if (IsPedInAnyVehicle(ped, false)) then
				isInVehicle = true;
                restoreRadar = not IsRadarHidden();
                local veh = GetVehiclePedIsIn(ped, false);
                local model = GetEntityModel(veh);
                for k,v in next, Config.Vehicles do
                    if (model == GetHashKey(v.model)) then
                        inPlane = true;
                        currentColor = v.color;
                        retractableGear = v.retractableGear;
                        hasVtol = v.vtol;
                        EnableStallWarningSounds(veh, false);
                        if ((Config.OnlyFirstPerson and GetFollowVehicleCamViewMode() == 4) or not Config.OnlyFirstPerson) then
                            SendNUIMessage({
                                action = "show",
                                color = currentColor
                            });
                        end
                        break;
                    end
                end
			end
		elseif (isInVehicle) then
			if (not IsPedInAnyVehicle(ped, false) or IsPlayerDead(ped)) then
				isInVehicle = false;
                inPlane = false;
                SendNUIMessage({
                    action = "hide"
                });
                if (restoreRadar) then
                    DisplayRadar(true);
                end
			end
		end
	end
end);