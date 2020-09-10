local x = ScrW()
local y = ScrH()
local active = false
local lastactive = 0
local InfoTable1 = {}
local InfoTable2 = {}
local InfoTable3 = {}

if !GetConVar( "EnableDakTankInfoScanner" ) then
	CreateClientConVar( "EnableDakTankInfoScanner", "1", true, false )
end

surface.CreateFont( "DakTankHudFont1", {
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
	outline = true,
})

surface.CreateFont( "DakTankHudFont2", {
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
	outline = true,
})

hook.Add( "AddToolMenuCategories", "CustomCategory", function()
	spawnmenu.AddToolCategory( "Utilities", "DakTank", "#Daktank" )
end )

hook.Add( "PopulateToolMenu", "CustomMenuSettings", function()
	spawnmenu.AddToolMenuOption( "Utilities", "DakTank", "Custom_Menu", "#DakTank Info Scanner", "", "", function( panel )
		panel:ClearControls()
		panel:CheckBox( "Enable DakTank Info Scanner", "EnableDakTankInfoScanner" )
		-- Add stuff here
	end )
end )

net.Receive( "daktankhud", function()
	InfoTable1 = util.JSONToTable(net.ReadString())
	InfoTable2 = util.JSONToTable(net.ReadString())
	InfoTable3 = util.JSONToTable(net.ReadString())

	active = true
	lastactive = CurTime()
	timer.Simple( 1, function() 
		if CurTime() - lastactive > 0.5 then
			active = false 
		end
	end )
end )

hook.Add("HUDPaint", "DakTankInfoReadout", function()
	if active and GetConVar( "EnableDakTankInfoScanner" ):GetString() == "1" then
		surface.SetDrawColor(0,0,0,200)
	    surface.DrawRect(x*0.05, y*0.2, 450, 60+25*(#InfoTable1+#InfoTable2+#InfoTable3))
	    surface.SetDrawColor(0,255,0,255)
	    surface.DrawOutlinedRect( x*0.05, y*0.2, 450, 60+25*(#InfoTable1+#InfoTable2+#InfoTable3))
	    local spacing = 0
	    for i=1, #InfoTable1 do
	    	draw.DrawText(InfoTable1[i], "DakTankHudFont1", x*0.05 + 10, y*0.2+5 + spacing, Color(0,255,0,255), TEXT_ALIGN_LEFT)
	    	spacing = spacing + 25
	    end
	    for i=1, #InfoTable2 do
	    	draw.DrawText(InfoTable2[i], "DakTankHudFont1", x*0.05 + 10, y*0.2+5 + spacing, Color(0,255,0,255), TEXT_ALIGN_LEFT)
	    	spacing = spacing + 25
	    end
	    for i=1, #InfoTable3 do
	    	draw.DrawText(InfoTable3[i], "DakTankHudFont1", x*0.05 + 10, y*0.2+5 + spacing, Color(255,0,0,255), TEXT_ALIGN_LEFT)
	    	spacing = spacing + 25
	    end
	    spacing = spacing + 25
	    draw.DrawText("This panel can be disabled at any time via the utilities menu.", "DakTankHudFont2", x*0.05 + 10, y*0.2+5 + spacing, Color(0,255,0,255), TEXT_ALIGN_LEFT)
	end
end)