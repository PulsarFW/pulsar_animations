function StartPointing()
    if not plsr.State.flags.loggedIn or _isPointing or IsPedArmed(PlayerPedId(), 7) or GLOBAL_VEH then return end
    _isPointing = true

    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(100)
    end

    SetPedConfigFlag(PlayerPedId(), 36, 1)
    TaskMoveNetworkByName(PlayerPedId(), "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")

    CreateThread(function()
        while _isPointing do
            if GLOBAL_VEH or IsPedArmed(PlayerPedId(), 7) then
                return StopPointing()
            end
            if IsTaskMoveNetworkActive(PlayerPedId()) then
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = math.cos(camHeading)
                local sinCamHeading = math.sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                local blocked = 0
                local nn = 0

                local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local nn, blocked = GetRaycastResult(StartShapeTestCapsule(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, PlayerPedId(), 7))

                SetTaskMoveNetworkSignalFloat(PlayerPedId(), "Pitch", camPitch)
                SetTaskMoveNetworkSignalFloat(PlayerPedId(), "Heading", camHeading * -1.0 + 1.0)
                SetTaskMoveNetworkSignalBool(PlayerPedId(), "isBlocked", blocked)
                SetTaskMoveNetworkSignalBool(PlayerPedId(), "isFirstPerson", N_0xee778f8c7e1142e2(N_0x19cafa3c87f7c2ff()) == 4)
            end
            Wait(5)
        end
    end)
end

function StopPointing()
    if not _isPointing then return end
    _isPointing = false
    
    RequestTaskMoveNetworkStateTransition(PlayerPedId(), "Stop")
    if not IsPedInjured(PlayerPedId()) then
        ClearPedSecondaryTask(PlayerPedId())
    end

    SetPedConfigFlag(PlayerPedId(), 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end
