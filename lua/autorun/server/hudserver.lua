local LastThink = CurTime()
util.AddNetworkString( "daktankhud" )
hook.Add( "Think", "DakTankInfoScannerFunction", function()
	if CurTime()-1 >= LastThink then
		for i=1, #player.GetAll() do
			local CurPlayer = player.GetAll()[i]
			if not(CurPlayer:InVehicle()) then
				local HitEnt = CurPlayer:GetEyeTraceNoCursor().Entity
				if HitEnt.Controller then
					local Target = HitEnt.Controller
					if Target.Cost then
						local InfoTable1 = {}
						local InfoTable2 = {}
						local InfoTable3 = {}

						InfoTable1[1] = "DakTank Info Scanner"
						local Era = "WWII"
						if Target.ColdWar == 1 then
							Era = "Cold War"
						end
						if Target.Modern == 1 then
							Era = "Modern"
						end
						InfoTable1[2] = Target.Cost.." point "..Era.." "..math.Round(Target.TotalMass*0.001,2).." ton tank."
						InfoTable1[3] = "-Best Average Armor: "..(math.Round(Target.BestAveArmor,2)).."mm"
						InfoTable1[4] = "-Best Round Pen: "..math.Round(Target.MaxPen,2).."mm"
						if Target.Gearbox ~= nil and Target.Gearbox.DakHP ~= nil then
							InfoTable1[5] = "-HP/T: "..math.Round(math.Clamp(Target.Gearbox.DakHP,0,Target.Gearbox.MaxHP)/(Target.Gearbox.TotalMass/1000),2).."."
						else
							InfoTable1[5] = "-HP/T: 0."
						end
						
						InfoTable1[6] = "-Crew Count: "..(#Target.Crew)

						
						local info2count = 1
						InfoTable2[info2count] = "Guns"
						local GunsSorted = table.Copy( Target.Guns )
						table.sort( GunsSorted, function(a, b)
							if a.DakMass ~= nil and b.DakMass ~= nil then
								return a.DakMass > b.DakMass 
							else
								return false
							end
						end )
						for i = 1, #GunsSorted do
							info2count = info2count + 1
							if GunsSorted[i].DakName ~= nil then
								InfoTable2[info2count] = "-"..GunsSorted[i].DakName
							else
								InfoTable2[info2count] = "-N/A"
							end
						end
						info2count = info2count + 1
						local TurretsSorted = table.Copy( Target.TurretControls )
						table.sort( TurretsSorted, function(a, b)
							if a.DakMass ~= nil and b.DakMass ~= nil then
								return a.DakMass > b.DakMass 
							else
								return false
							end
						end )

						InfoTable2[info2count] = "Turrets: "..(#TurretsSorted)
						for i=1, #TurretsSorted do
							info2count = info2count + 1
							InfoTable2[info2count] = "-Turret "..i
							info2count = info2count + 1
							if TurretsSorted[i].DakTurretMotors ~= nil then
								InfoTable2[info2count] = "--Motors: "..(#TurretsSorted[i].DakTurretMotors)
							else
								InfoTable2[info2count] = "--Motors: N/A"
							end
							info2count = info2count + 1
							if TurretsSorted[i].GunMass ~= nil then
								InfoTable2[info2count] = "--Weight: "..math.Round(TurretsSorted[i].GunMass/1000,2).." tons"
							else
								InfoTable2[info2count] = "--Weight: N/A tons"
							end
							info2count = info2count + 1
							if TurretsSorted[i].RotationSpeed ~= nil then
								InfoTable2[info2count] = "--Speed: "..math.Round((TurretsSorted[i].RotationSpeed*1/engine.TickInterval()),2).." degrees/s"
							else
								InfoTable2[info2count] = "--Speed: N/A degrees/s"
							end
						end

						InfoTable3[1] = "Debugging"
						local info3count = 1

						--turret gunner detection
						if TurretsSorted[1] ~= NULL then
							for i=1, #TurretsSorted do
								if TurretsSorted[i].DakCrew == NULL then
									info3count = info3count + 1
									InfoTable3[info3count] = "-"..TurretsSorted[i].DakName.." #"..TurretsSorted[i]:EntIndex().." gunner not detected"
								else
									if not(Target.ColdWar == 1 or Target.Modern == 1) then
										if IsValid(TurretsSorted[i].TurretBase) and (TurretsSorted[i]:GetYawMin()+TurretsSorted[i]:GetYawMax()>90) then
											if TurretsSorted[i].DakCrew:IsValid() then
												if TurretsSorted[i].DakCrew:GetParent():IsValid() then
													if TurretsSorted[i].DakCrew:GetParent():GetParent():IsValid() then
														if TurretsSorted[i].DakCrew:GetParent():GetParent() ~= TurretsSorted[i].TurretBase and TurretsSorted[i].DakCrew:GetParent():GetParent() ~= TurretsSorted[i].DakGun then
															info3count = info3count + 1
															InfoTable3[info3count] = "-"..TurretsSorted[i].DakName.." #"..TurretsSorted[i]:EntIndex().." gunner not in turret"
														end
													end
												end
											end
										end
										if not(IsValid(TurretsSorted[i].TurretBase)) and (TurretsSorted[i]:GetYawMin()+TurretsSorted[i]:GetYawMax()>90) then
											if TurretsSorted[i].DakCrew:IsValid() then
												if TurretsSorted[i].DakCrew:GetParent():IsValid() then
													if TurretsSorted[i].DakCrew:GetParent():GetParent():IsValid() then
														if TurretsSorted[i].DakCrew:GetParent():GetParent() == TurretsSorted[i]:GetParent():GetParent() or TurretsSorted[i].DakCrew:GetParent():GetParent() == TurretsSorted[i].DakGun then
															info3count = info3count + 1
															InfoTable3[info3count] = "-"..TurretsSorted[i].DakName.." #"..TurretsSorted[i]:EntIndex().." gunner not in hull"
														end
													end
												end
											end
										end
									end
								end
							end
						end

						--crew count check
						if Target.Crew ~= nil then
							if (#Target.Crew) < 2 then
								info3count = info3count + 1
								InfoTable3[info3count] = "-Not enough crew"
							end
						end

						--driver check
						if Target.Gearbox ~= nil and Target.Gearbox.CrewAlive ~= nil then
							if Target.Gearbox.CrewAlive == 0 then
								info3count = info3count + 1
								InfoTable3[info3count] = "-No Driver"
							end
						end

						--fuel check
						if Target.Gearbox ~= nil and Target.Gearbox.DakFuel ~= nil and Target.Gearbox.DakFuelReq ~= nil then
							if Target.Gearbox.DakFuel < Target.Gearbox.DakFuelReq then
								info3count = info3count + 1
								InfoTable3[info3count] = "-"..Target.Gearbox.DakFuel.." out of "..Target.Gearbox.DakFuelReq.." Fuel available"
							end
						end

						--autoloader check
						for i = 1, #GunsSorted do
							if GunsSorted[i].IsAutoLoader ~= nil then
								if GunsSorted[i].IsAutoLoader == 1 then
									if not(GunsSorted[i].Loaded == 1) then
										info3count = info3count + 1
										InfoTable3[info3count] = "-"..GunsSorted[i].DakName.." needs mag"
									end
								end
							end
						end
						

						--all clear
						if info3count == 1 then
							info3count = info3count + 1
							InfoTable3[info3count] = "-All Clear"
						end
						net.Start( "daktankhud" )
						net.WriteString( util.TableToJSON( InfoTable1 ) )
						net.WriteString( util.TableToJSON( InfoTable2 ) )
						net.WriteString( util.TableToJSON( InfoTable3 ) )
						net.Send( CurPlayer )
					end
				end
			end
		end
		LastThink = CurTime()
	end
end )