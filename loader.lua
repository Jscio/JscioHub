getgenv().JscioHub = "https://raw.githubusercontent.com/Jscio/JscioHub/main"

if game.PlaceId == 2413927524 then
    loadstring(game:HttpGet(getgenv().JscioHub .. "/Games/" .. 2413927524 .. "/src.lua"))()
end