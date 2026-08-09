-- sleepless_interact's option schema (name, icon, label, distance, canInteract, onSelect)
-- matches our normalized schema, so no translation needed here. Note: its icon
-- field expects a bare icon name (no "fa-solid fa-" prefix) — options defined for
-- ox_target won't render correctly here without adjusting the icon strings.
return {
    IsAvailable = function()
        return GetResourceState("sleepless_interact") == "started"
    end,

    AddLocalEntity = function(entity, options)
        exports.sleepless_interact:addLocalEntity(entity, options)
    end,

    RemoveLocalEntity = function(entity, names)
        exports.sleepless_interact:removeLocalEntity(entity, names)
    end,
}
