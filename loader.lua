if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BASE = 'https://raw.githubusercontent.com/flontify/ShinyHub/refs/heads/main/games/'

local games = {
    [10529067596] = 'hitagolfball.lua',
    [8884433153] = 'collectallpets.lua',
}

if identifyexecutor then
    local execName = tostring(identifyexecutor()):lower()
    local UNSUPPORTED = { "Solara", "Xeno" }
    for _, name in ipairs(UNSUPPORTED) do
        if execName:find(name:lower(), 1, true) then
            local ok, Library = pcall(function()
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/Library.lua"))()
            end)
            if ok and Library then
                Library:CreateUnsupportedScreen({
                    Title = "ShinyHub",
                    Unsupported = UNSUPPORTED,
                    Footer = { { Text = "https://discord.gg/qgUGqmCxb3", Copyable = true } },
                })
            end
            return
        end
    end
end

local file = games[game.GameId] or games[game.PlaceId]

if file then
    task.wait(math.random())
    pcall(function()
        loadstring(game:HttpGet(BASE .. 'donation.lua'))()
    end)
    loadstring(game:HttpGet(BASE .. file))()
else
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="ShinyHub", Text="Game not supported", Duration=5})
end
