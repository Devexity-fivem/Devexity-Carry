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
            
            -- Box top
            print(MAGENTA .. "======================================================" .. RESET)
            
            -- Colored ASCII art with outline
            print(BLUE .. "DDDDD   EEEEE  V   V  EEEEE  X   X  III  TTTTT  Y   Y" .. RESET)
            print(CYAN .. "D    D  E      V   V  E       X X    I     T     Y Y " .. RESET)
            print(GREEN .. "D    D  EEEE   V   V  EEEE     X     I     T      Y  " .. RESET)
            print(YELLOW .. "D    D  E      V   V  E       X X    I     T      Y  " .. RESET)
            print(MAGENTA .. "DDDDD   EEEEE   V V   EEEEE  X   X  III    T      Y  " .. RESET)
            
            -- Box bottom
            print(MAGENTA .. "======================================================" .. RESET)
            
            -- Subtext
            print(CYAN .. "            Thanks for using Devexity Scripts!              " .. RESET)
        end)
    end
end)