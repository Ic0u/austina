-- Compatibility adapter for legacy tab-style feature code. Controls are
-- rendered exclusively by Vinsers Hub's shared UI library.

local Adapter = {}

local function firstDefault(value)
    if type(value) == "table" then
        return value[1]
    end

    if value == false then
        return nil
    end

    return value
end

local function wrapLabel(handle)
    return {
        Set = function(_, value)
            if handle and handle.SetText then
                handle.SetText(tostring(value))
            end
        end,
    }
end

local function wrapDropdown(handle, initialItems)
    local items = {}
    for _, item in ipairs(initialItems or {}) do
        table.insert(items, item)
    end

    local wrapper = {}

    function wrapper:Clear()
        items = {}
        if handle and handle.GetNewList then
            handle.GetNewList(items)
        end
    end

    function wrapper:Add(item)
        table.insert(items, item)
        if handle and handle.GetNewList then
            handle.GetNewList(items)
        end
    end

    function wrapper:Refresh(newItems)
        items = newItems or {}
        if handle and handle.GetNewList then
            handle.GetNewList(items)
        end
    end

    function wrapper:Set(value)
        if handle and handle.Set then
            handle.Set(value)
        end
    end

    return wrapper
end

local function wrapSection(nativeSection)
    local section = {}

    function section:Toggle(name, default, callback)
        local handle = nativeSection.CreateToggle({
            Title = tostring(name),
            Default = default == true,
        }, callback)

        return {
            Update = function(_, value)
                if handle and handle.Set then
                    handle.Set(value)
                end
            end,
        }
    end

    function section:Button(name, callbackOrDefault, possibleCallback)
        local callback = type(callbackOrDefault) == "function" and callbackOrDefault or possibleCallback
        return nativeSection.CreateButton({ Title = tostring(name) }, callback)
    end

    function section:Label(text)
        return wrapLabel(nativeSection.CreateLabel({ Title = tostring(text) }))
    end

    function section:Seperator(text)
        return nativeSection.CreateLabel({ Title = "— " .. tostring(text) .. " —" })
    end

    section.Separator = section.Seperator

    function section:Dropdown(name, list, default, callback)
        local items = list or {}
        local handle = nativeSection.CreateDropdown({
            Title = tostring(name),
            List = items,
            Default = firstDefault(default),
            Search = #items > 12,
        }, callback)
        return wrapDropdown(handle, items)
    end

    function section:Textbox(name, placeholder, callback)
        return nativeSection.CreateBox({
            Title = tostring(name),
            Placeholder = tostring(placeholder or "Enter value..."),
        }, callback)
    end

    function section:Slider(name, wholeNumbers, minimum, maximum, default, callback)
        return nativeSection.CreateSlider({
            Title = tostring(name),
            Min = tonumber(minimum) or 0,
            Max = tonumber(maximum) or 100,
            Default = tonumber(default) or tonumber(minimum) or 0,
            Precise = not wholeNumbers,
        }, callback)
    end

    return section
end

function Adapter.Create(uiLibrary, options)
    local window = uiLibrary.CreateMain(options)
    local compatibilityWindow = {}

    function compatibilityWindow:Tab(name)
        local page = window.CreatePage({
            Page_Name = tostring(name),
            Page_Title = tostring(name),
        })
        local tab = {}

        function tab:Section(sectionName, side)
            -- The legacy library used this argument for column placement. Vinsers Hub's
            -- second CreateSection argument controls whether a section exists, so
            -- mapping "Left" to false silently removed half of the interface.
            return wrapSection(page.CreateSection(tostring(sectionName)))
        end

        return tab
    end

    compatibilityWindow.Native = window
    return compatibilityWindow
end


return Adapter
