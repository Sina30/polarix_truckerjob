-- ox_target option schema (name, icon, label, distance, canInteract, onSelect) is
-- our normalized schema itself, so no translation needed here.
return {
    IsAvailable = function()
        return GetResourceState("ox_target") == "started"
    end,

    AddLocalEntity = function(entity, options)
        exports.ox_target:addLocalEntity(entity, options)
    end,

    RemoveLocalEntity = function(entity, names)
        exports.ox_target:removeLocalEntity(entity, names)
    end,
}
