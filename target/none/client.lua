-- No target system configured — feature modules fall back to their own
-- TextUI/marker interaction path when IsAvailable() is false.
return {
    IsAvailable = function() return false end,
    AddLocalEntity = function() end,
    RemoveLocalEntity = function() end,
}
