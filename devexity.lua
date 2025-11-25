AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.CreateThread(function()
            Citizen.Wait(15000) -- Wait for 15000 milliseconds (15 seconds)
            
            -- ANSI color codes
            local BLUE = "\27[34m"
            local CYAN = "\27[36m"
            local GREEN = "\27[32m"
            local YELLOW = "\27[33m"
            local MAGENTA = "\27[35m"
            local RESET = "\27[0m"
            
            -- top border
            print(MAGENTA .. "======================================================================================================" .. RESET)

            -- stylized ASCII title (Devexity)
            print(BLUE   .. " /$$$$$$$                                          /$$   /$$                     /$$$$$$$                       /$$                                                         /$$    " .. RESET)
            print(CYAN   .. "| $$__  $$                                        |__/  | $$                    | $$__  $$                     | $$                                                        | $$    " .. RESET)
            print(GREEN  .. "| $$  \\ $$  /$$$$$$  /$$    /$$ /$$$$$$  /$$   /$$ /$$ /$$$$$$   /$$   /$$      | $$  \\ $$  /$$$$$$  /$$    /$$| $$  /$$$$$$   /$$$$$$  /$$$$$$/$$$$   /$$$$$$  /$$$$$$$  /$$$$$$  " .. RESET)
            print(YELLOW .. "| $$  | $$ /$$__  $$|  $$  /$$//$$__  $$|  $$ /$$/| $$|_  $$_/  | $$  | $$      | $$  | $$ /$$__  $$|  $$  /$$/| $$ /$$__  $$ /$$__  $$| $$_  $$_  $$ /$$__  $$| $$__  $$|_  $$_/  " .. RESET)
            print(MAGENTA.. "| $$  | $$| $$$$$$$$ \\  $$/$$/| $$$$$$$$ \\  $$$$/ | $$  | $$    | $$  | $$      | $$  | $$| $$$$$$$$ \\  $$/$$/ | $$| $$  \\ $$| $$  \\ $$| $$ \\ $$ \\ $$| $$$$$$$$| $$  \\ $$  | $$    " .. RESET)
            print(BLUE   .. "| $$  | $$| $$_____/  \\  $$$/ | $$_____/  >$$  $$ | $$  | $$ /$$| $$  | $$      | $$  | $$| $$_____/  \\  $$$/  | $$| $$  | $$| $$  | $$| $$ | $$ | $$| $$_____/| $$  | $$  | $$ /$$" .. RESET)
            print(CYAN   .. "| $$$$$$$/|  $$$$$$$   \\  $/  |  $$$$$$$ /$$/\\  $$| $$  |  $$$$/|  $$$$$$$      | $$$$$$$/|  $$$$$$$   \\  $/   | $$|  $$$$$$/| $$$$$$$/| $$ | $$ | $$|  $$$$$$$| $$  | $$  |  $$$$/" .. RESET)
            print(GREEN  .. "|_______/  \\_______/    \\_/    \\_______/|__/  \\__/|__/   \\___/   \\____  $$      |_______/  \\_______/    \\_/    |__/ \\______/ | $$____/ |__/ |__/ |__/ \\_______/|__/  |__/   \\___/  " .. RESET)
            print(YELLOW .. "                                                                 /$$  | $$                                                   | $$                                                   " .. RESET)
            print(MAGENTA.. "                                                                |  $$$$$$/                                                   | $$                                                   " .. RESET)
            print(BLUE   .. "                                                                 \\______/                                                    |__/                                                   " .. RESET)

            -- tag line
            print(CYAN ..    "                 Carry the vibe • Devexity Scripts • 2025                 " .. RESET)

            -- bottom border
            print(MAGENTA .. "======================================================================================================" .. RESET)
        end)
    end
end)