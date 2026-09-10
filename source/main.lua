-- bullshitxd main (step 1): 4 tabs + barebones aimbot (lock only, no checks).
-- Bump UI_URL when source/ui.lua changes upstream.
local UI_URL = "https://raw.githubusercontent.com/ywhshhs/bs-xd/ccd85117db62527a0b380e73ed84c33313f02ba8/source/ui.lua"

if getgenv().bsxd then
    pcall(function() getgenv().bsxd.unload() end)
end

local library = loadstring(game:HttpGet(UI_URL))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local S = { aimbot = false }
getgenv().bsxd = {
    state = S,
    unload = function()
        S.aimbot = false
        pcall(function() RunService:UnbindFromRenderStep("bsxd_aim") end)
        pcall(function() library:unload() end)
    end,
}

local window = library:window({ name = "bullshitxd" })
local mainTab = window:tab({ name = "Main" })
local moveTab = window:tab({ name = "Movement" })
local visTab = window:tab({ name = "Visuals" })
local setTab = window:tab({ name = "Settings" })

-- empty placeholders (wired later)
moveTab:section({ name = "Placeholder", side = "left" })
visTab:section({ name = "Placeholder", side = "left" })
setTab:section({ name = "Placeholder", side = "left" })

-- barebones aimbot: closest head, camera snap. No team/wall/fov checks.
local aimSec = mainTab:section({ name = "Aimbot", side = "left" })
aimSec:toggle({
    name = "Enabled",
    flag = "aimbot_enabled",
    default = false,
    callback = function(v) S.aimbot = v end,
})

local function headOf(c)
    if not c then return nil end
    local h = c:FindFirstChild("Head")
    if h and h:IsA("BasePart") then return h end
    return nil
end

RunService:BindToRenderStep("bsxd_aim", Enum.RenderPriority.Camera.Value + 1, function()
    if not S.aimbot then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local best, bestD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            local hd = headOf(c)
            if hd and hum and hum.Health > 0 then
                local d = (hd.Position - cam.CFrame.Position).Magnitude
                if d < bestD then best, bestD = hd, d end
            end
        end
    end
    if best then
        cam.CFrame = CFrame.new(cam.CFrame.Position, best.Position)
    end
end)

print("[bsxd] loaded")
