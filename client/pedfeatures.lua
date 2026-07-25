local myFeatures = {}
local crouchAnimSet = "move_ped_crouched"
local crouchStrafeAnimSet = "move_ped_crouched_strafing"

function RequestAndLoadAnimSet(animSet)
    RequestAnimSet(crouchAnimSet)
    while not HasAnimSetLoaded(crouchAnimSet) do
        Wait(10)
    end
end

ANIMATIONS.PedFeatures = {
    ToggleCrouch = function(self, toggle)
        if toggle == nil then
            toggle = not _isCrouched
        end

        if toggle then
            if IsPedOnFoot(PlayerPedId()) and not plsr.State.flags.placingFurniture then
                if not plsr.State.flags.isLimping then
                    RequestAndLoadAnimSet(crouchAnimSet)
                    --RequestAndLoadAnimSet(crouchStrafeAnimSet)

                    SetPedMovementClipset(PlayerPedId(), crouchAnimSet, 1.0)
                    --SetPedWeaponMovementClipset(PlayerPedId(), crouchAnimSet, 1.0)
                    --SetPedStrafeClipset(PlayerPedId(), crouchStrafeAnimSet, 1.0)

                    _isCrouched = true
                else
                    SetPedToRagdoll(PlayerPedId(), 1500, 2000, 3, true, true, false)
                end
            end
        else
            ResetPedMovementClipset(PlayerPedId(), 0)

            ResetPedWeaponMovementClipset(PlayerPedId())
            ResetPedStrafeClipset(PlayerPedId())

            if not plsr.State.flags.drunkMovement then
                plsr.Animations.PedFeatures:RequestFeaturesUpdate()
            end
            _isCrouched = false
        end
    end,
    SetWalk = function(self, walk, label)
        if plsr.State.flags.isLimping then
            RequestAnimSet("move_m@injured")
            SetPedMovementClipset(PlayerPedId(), "move_m@injured", 0.2)
            RemoveAnimSet("move_m@injured")
            if walk == 'reset' then
                walkStyle = walk
                plsr.Callbacks:ServerCallback('Animations:UpdatePedFeatures', { type = 'walk', data = 'default'}, function(success)
                    if success then
                        plsr.Notification:Info('Reset Walking Style', 5000)
                    end
                end)
            else
                walkStyle = walk
                plsr.Callbacks:ServerCallback('Animations:UpdatePedFeatures', { type = 'walk', data = walk}, function(success)
                    if success then
                        plsr.Notification:Success('Saved Walking Style: ' .. label, 5000)
                    end
                end)
            end
        else
            if walk == 'reset' then
                ResetPedMovementClipset(PlayerPedId(), 0.0)
                walkStyle = walk
                plsr.Callbacks:ServerCallback('Animations:UpdatePedFeatures', { type = 'walk', data = 'default'}, function(success)
                    if success then
                        plsr.Notification:Info('Reset Walking Style', 5000)
                    end
                end)
            else
                ReqAnimSet(walk)
                SetPedMovementClipset(PlayerPedId(), walk, 0.2)
                RemoveAnimSet(walk)
                walkStyle = walk
                plsr.Callbacks:ServerCallback('Animations:UpdatePedFeatures', { type = 'walk', data = walk}, function(success)
                    if success then
                        plsr.Notification:Success('Saved Walking Style: ' .. label, 5000)
                    end
                end)
            end
        end
    end,
    SetExpression = function(self, expression, label)
        if expression == 'reset' then
            ClearFacialIdleAnimOverride(PlayerPedId())
            facialExpression = expression
            plsr.Callbacks:ServerCallback('Animations:UpdatePedFeatures', { type = 'expression', data = 'default'}, function(success)
                if success then
                    plsr.Notification:Info('Expression Reset', 5000)
                end
            end)
        else
            SetFacialIdleAnimOverride(PlayerPedId(), expression, 0)
            facialExpression = expression
            plsr.Callbacks:ServerCallback('Animations:UpdatePedFeatures', { type = 'expression', data = expression}, function(success)
                if success then
                    plsr.Notification:Success('Saved Expression: ' .. label, 5000)
                end
            end)
        end
    end,
    RequestFeaturesUpdate = function(self, feats)
        if plsr.State.flags.isLimping then
            RequestAnimSet("move_m@injured")
            SetPedMovementClipset(PlayerPedId(), "move_m@injured", 0.2)
            RemoveAnimSet("move_m@injured")
        else
            if walkStyle ~= 'default' then
                ReqAnimSet(walkStyle)
                SetPedMovementClipset(PlayerPedId(), walkStyle, 0.6)
                RemoveAnimSet(walkStyle)
            else
                ResetPedMovementClipset(PlayerPedId(), 0.0)
            end
        end
        if facialExpression ~= 'default' then
            SetFacialIdleAnimOverride(PlayerPedId(), facialExpression, 0)
        end
    end,
}