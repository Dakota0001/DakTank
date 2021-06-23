local x = ScrW()
local y = ScrH()
local InfoTable1 = {}
local InfoTable2 = {}
local InfoTable3 = {}
local FrontArmor = {}
local Tally      = 0
local CanDraw    = CreateClientConVar("EnableDakTankInfoScanner", "1", true, true):GetBool()

surface.CreateFont("DakTankHudFont1", {
	font = "Arial",
	extended = false,
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = true
})

surface.CreateFont("DakTankHudFont2", {
	font = "Arial",
	extended = false,
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = true
})

hook.Add("AddToolMenuCategories", "DakTankInfoScannerAddToolMenuCategories", function()
	spawnmenu.AddToolCategory("Utilities", "DakTank", "#DakTank")
end)

hook.Add("PopulateToolMenu", "DakTankInfoScannerPopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Utilities", "DakTank", "DakTankInfoScannerMenu", "#DakTank Info Scanner", "", "", function(panel)
		panel:ClearControls()
		panel:CheckBox("Enable DakTank Info Scanner", "EnableDakTankInfoScanner")
	end)
end)

-- Add stuff here
local function StopDrawing()
	hook.Remove("HUDPaint", "DakTankInfoReadout")
end

local function DrawReadout()
	-- Stop drawing when we sit in a vehicle
	if LocalPlayer():InVehicle() then
		StopDrawing()

		return
	else
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(x * 0.05, y * 0.2, 450, 60 + 25 * Tally)
		surface.SetDrawColor(0, 255, 0, 255)
		surface.DrawOutlinedRect(x * 0.05, y * 0.2, 450, 60 + 25 * Tally)
		local spacing = 0

		for i = 1, #InfoTable1 do
			draw.DrawText(InfoTable1[i], "DakTankHudFont1", x * 0.05 + 10, y * 0.2 + 5 + spacing, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT)
			spacing = spacing + 25
		end

		for i = 1, #InfoTable2 do
			draw.DrawText(InfoTable2[i], "DakTankHudFont1", x * 0.05 + 10, y * 0.2 + 5 + spacing, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT)
			spacing = spacing + 25
		end

		for i = 1, #InfoTable3 do
			draw.DrawText(InfoTable3[i], "DakTankHudFont1", x * 0.05 + 10, y * 0.2 + 5 + spacing, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT)
			spacing = spacing + 25
		end

		spacing = spacing + 25
		draw.DrawText("This panel can be disabled at any time via the utilities menu.", "DakTankHudFont2", x * 0.05 + 10, y * 0.2 + 5 + spacing, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT)
		local yadd = 60 + 25 * Tally - 200
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(x * 0.05 + 475, y * 0.2 + yadd, 200, 200)
		surface.SetDrawColor(0, 255, 0, 255)
		surface.DrawOutlinedRect(x * 0.05 + 475, y * 0.2 + yadd, 200, 200)
		local pixels = 100
		local curpixel = 0
		local pixelsize = 200 / pixels

		if #FrontArmor > pixels * pixels then
			local maxarmor = FrontArmor[#FrontArmor] * 1.5

			for i = 1, pixels do
				for j = 1, pixels do
					curpixel = curpixel + 1

					if FrontArmor[curpixel] ~= 0 then
						surface.SetDrawColor(255 * (FrontArmor[curpixel] / maxarmor), 255 - 255 * math.min(1, FrontArmor[curpixel] / maxarmor), 0, 200)
						surface.DrawRect(x * 0.05 + 475 + 200 - (1 * pixelsize * j), y * 0.2 + yadd + (1 * pixelsize * i), pixelsize, pixelsize)
					end
				end
			end
		end
	end
end

local function StartDrawing()
	hook.Add("HUDPaint", "DakTankInfoReadout", DrawReadout)
end

net.Receive("daktankhud", function()
	InfoTable1 = util.JSONToTable(net.ReadString())
	InfoTable2 = util.JSONToTable(net.ReadString())
	InfoTable3 = util.JSONToTable(net.ReadString())
	FrontArmor = util.JSONToTable(net.ReadString())

	Tally = #InfoTable1 + #InfoTable2 + #InfoTable3

	if CanDraw and #FrontArmor == 0 then
		StopDrawing()
	else
		StartDrawing()
	end
end)

cvars.AddChangeCallback("EnableDakTankInfoScanner", function(_, _, New)
	local Value = tobool(New)
	CanDraw = Value

	if not CanDraw then
		StopDrawing()
	end
end)