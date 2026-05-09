TCS = TCS or {}
TCS.Logger = {}

local LOG_PREFIX = "[TCS] "
TCS.Logger.DEBUG_MODE = true -- Set to false in production to silence trace logs

-- Internal helper to format tables matching the LotAtc output style
local function formatTable(tbl, indent, depth, maxDepth, seen)
    indent = indent or "   "
    depth = depth or 0
    maxDepth = maxDepth or 4
    seen = seen or {}

    if depth > maxDepth then
        return indent .. "- <Max Depth Reached>"
    end

    -- Prevent DCS crashes from circular references (e.g., MOOSE objects)
    if seen[tbl] then
        return indent .. "- <Circular Reference: " .. tostring(tbl) .. ">"
    end
    seen[tbl] = true

    local lines = {}
    for k, v in pairs(tbl) do
        local keyStr = tostring(k)
        local valType = type(v)
        
        if valType == "table" then
            table.insert(lines, indent .. "- " .. keyStr .. " = " .. tostring(v) .. " " .. valType)
            local subLines = formatTable(v, indent .. "  ", depth + 1, maxDepth, seen)
            if subLines and subLines ~= "" then
                table.insert(lines, subLines)
            end
        else
            table.insert(lines, indent .. "- " .. keyStr .. " = " .. tostring(v) .. " " .. valType)
        end
    end
    
    return table.concat(lines, "\n")
end

-- Internal helper to ensure every newline gets the DCS timestamp + [TCS] prefix
local function emitLog(msg, level)
    -- Split by newline and log each line individually
    for line in string.gmatch(msg, "[^\r\n]+") do
        if level == "error" then
            env.error(LOG_PREFIX .. line)
        elseif level == "warn" then
            env.warning(LOG_PREFIX .. line)
        else
            env.info(LOG_PREFIX .. line)
        end
    end
end

function TCS.Logger.info(msg, ...)
    if type(msg) == "table" then
        emitLog("Extracting table data:\n" .. formatTable(msg), "info")
    else
        local formatted = select('#', ...) > 0 and string.format(msg, ...) or tostring(msg)
        emitLog(formatted, "info")
    end
end

function TCS.Logger.warn(msg, ...)
    if type(msg) == "table" then
        emitLog("Extracting table data:\n" .. formatTable(msg), "warn")
    else
        local formatted = select('#', ...) > 0 and string.format(msg, ...) or tostring(msg)
        emitLog(formatted, "warn")
    end
end

function TCS.Logger.error(msg, ...)
    if type(msg) == "table" then
        emitLog("Extracting table data:\n" .. formatTable(msg), "error")
    else
        local formatted = select('#', ...) > 0 and string.format(msg, ...) or tostring(msg)
        emitLog(formatted, "error")
    end
end

-- Used for pipeline tracking (e.g. entering the Spawner, Dispatcher, etc)
function TCS.Logger.trace(msg, ...)
    if TCS.Logger.DEBUG_MODE then
        local formatted = select('#', ...) > 0 and string.format(msg, ...) or tostring(msg)
        emitLog("--------------- " .. formatted, "info")
    end
end