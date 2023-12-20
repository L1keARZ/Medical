local imgui = require 'mimgui'
local encoding = require 'encoding'
local requests = require 'requests'

encoding.default = 'CP1251'
u8 = encoding.UTF8

local autofam = imgui.new.bool()
local WinState = imgui.new.bool()
local tab = 1

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
end)

imgui.OnFrame(function()
    return WinState[0]
end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(245, 270), imgui.Cond.Always)
    imgui.Begin(u8'Medical', WinState)

    if imgui.Button(u8'Главная', imgui.ImVec2(160, 40)) then
        tab = 1
    end

    if imgui.Button(u8'Настройки', imgui.ImVec2(160, 40)) then
        tab = 2
    end

    imgui.SetCursorPos(imgui.ImVec2(175, 33))
    if imgui.BeginChild('Name', imgui.ImVec2(-1, -1), true) then
        if tab == 1 then
            imgui.Checkbox("Heal radius", autofam)
        elseif tab == 2 then
            -- Ваши настройки для второй вкладки
        end
        imgui.EndChild()
    end
    imgui.End()
end)

local timer = os.clock()

function main()
    while not isSampAvailable() do
        wait(0)
    end

    local currentVersion = 1
    local githubVersion = 0

    local function updateScript()
        local response = requests.get("https://raw.githubusercontent.com/BostKing102/mobiletools/main/MedicalHelper.lua")
        
        if response.status_code == 200 then
            local f = assert(io.open('MedicalHelper.lua', 'wb'))
            f:write(response.text)
            f:close()
            sampAddChatMessage("Скрипт успешно обновлен!", -1)
        else
            sampAddChatMessage("Не удалось получить новую версию.", -1)
        end
    end

    sampRegisterChatCommand('mh', function()
        WinState[0] = not WinState[0]
    end)

    sampRegisterChatCommand('mhupdate', function()
        updateScript()
    end)

    while true do
        wait(0)
        if autofam[0] then
            lua_thread.create(function()
                local mx, my, mz = getCharCoordinates(playerPed)

                for id = 0, 1000 do
                    local _, handle = sampGetCharHandleBySampPlayerId(id)
                    if _ then
                        local x, y, z = getCharCoordinates(handle)
                        if getDistanceBetweenCoords3d(x, y, z, mx, my, mz) <= 10 then
                            if os.clock() - timer > 0.5 then
                                sampSendChat('/heal ' .. id .. ' 5000', -1)
                                timer = os.clock()
                            end
                        end
                    end
                end
            end)
        end
    end
end
