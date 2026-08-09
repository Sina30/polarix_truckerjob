local config = require("config.server")
local Locale = require("shared.locale")

Drivers = {}
DriverPayoutState = {} -- source -> { nextPayoutAt = <GetGameTimer() ms>, hiredSlots = { [slot]=true } }

local INTERVAL_MS = config.DriverIncomeIntervalMinutes * 60 * 1000

local function findSlotConfig(slot)
    for _, s in ipairs(config.DriverSlots) do
        if s.slot == slot then return s end
    end
    return nil
end

function Drivers.GetOwned(identifier)
    return DB.GetPlayerDriverSlots(identifier)
end

function Drivers.Hire(source, slot)
    local pData = Player.GetData(source)
    if not pData then return false, Locale("error.player_data_missing") end

    local slotConfig = findSlotConfig(slot)
    if not slotConfig then return false, Locale("error.driver_slot_not_found") end

    if pData.level < slotConfig.level_required then
        return false, Locale("error.level_required"):format(slotConfig.level_required)
    end

    local owned = DB.GetPlayerDriverSlots(pData.identifier)
    for _, s in ipairs(owned) do
        if s.slot == slot then return false, Locale("error.driver_already_hired") end
    end

    if Framework.GetMoney(source) < slotConfig.price then
        return false, Locale("error.not_enough_money")
    end
    Framework.RemoveMoney(source, slotConfig.price)
    DB.InsertDriverSlot(pData.identifier, slot)

    local state = DriverPayoutState[source]
    if state then state.hiredSlots[slot] = true end

    return true, slotConfig.price
end

-- Beim Login: hired Slots laden, Payout-Timer initialisieren
function Drivers.InitPlayer(source, identifier)
    local owned = DB.GetPlayerDriverSlots(identifier)
    local hiredSlots = {}
    for _, s in ipairs(owned) do hiredSlots[s.slot] = true end
    DriverPayoutState[source] = { nextPayoutAt = GetGameTimer() + INTERVAL_MS, hiredSlots = hiredSlots }
end

-- Payout-Thread: zahlt allen Online-Spielern mit angestellten Fahrern aus.
-- Nur online-Accrual, kein Offline-Catch-up (analog Rental-Billing-Thread).
CreateThread(function()
    while true do
        Wait(15000)
        local now = GetGameTimer()
        for source, state in pairs(DriverPayoutState) do
            if now >= state.nextPayoutAt then
                local total = 0
                for slot in pairs(state.hiredSlots) do
                    local slotConfig = findSlotConfig(slot)
                    if slotConfig then total = total + slotConfig.income end
                end
                if total > 0 then
                    Framework.AddMoney(source, total)
                    TriggerClientEvent("polarix_trucker:driverIncomePaid", source, total)
                end
                state.nextPayoutAt = now + INTERVAL_MS
            end
        end
    end
end)

lib.callback.register("polarix_trucker:hireDriver", function(source, slot)
    local success, result = Drivers.Hire(source, slot)
    if not success then return false, nil, result end
    return true, result, nil, DB.GetPlayerDriverSlots(Player.GetData(source).identifier)
end)

Framework.OnPlayerUnload(function(source)
    DriverPayoutState[source] = nil
end)
