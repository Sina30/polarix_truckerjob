-- Translates our normalized option schema (name, icon, label, distance, canInteract,
-- onSelect) into qb-target's AddTargetEntity shape: action(entity) instead of
-- onSelect(data), and distance lives on the call, not per option (largest wins).
local function ToQbTargetOptions(options)
    local qbOptions = {}
    local maxDistance = 0

    for i = 1, #options do
        local opt = options[i]
        qbOptions[i] = {
            icon = opt.icon,
            label = opt.label,
            canInteract = opt.canInteract,
            action = opt.onSelect,
        }
        if opt.distance and opt.distance > maxDistance then
            maxDistance = opt.distance
        end
    end

    return qbOptions, maxDistance
end

return {
    IsAvailable = function()
        return GetResourceState("qb-target") == "started"
    end,

    AddLocalEntity = function(entity, options)
        local qbOptions, maxDistance = ToQbTargetOptions(options)
        exports['qb-target']:AddTargetEntity(entity, {
            options = qbOptions,
            distance = maxDistance > 0 and maxDistance or 2.5,
        })
    end,

    -- qb-target removes options by label text, not by our "name" identifier —
    -- pass label(s) here when targeting this backend.
    RemoveLocalEntity = function(entity, names)
        exports['qb-target']:RemoveTargetEntity(entity, names)
    end,
}
