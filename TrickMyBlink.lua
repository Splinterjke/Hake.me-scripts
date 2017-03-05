local TrickMyBlink = {}

TrickMyBlink.IsToggled = Menu.AddOption( {"Utility", "TrickMyBlink"}, "Enabled", "")
TrickMyBlink.IsBlinkAbuse = Menu.AddOption( {"Utility", "TrickMyBlink"}, "Blink Abuze", "Abuse blink dagget via backpack to avoid 3 sec cooldown when enemy is attacking")
TrickMyBlink.BlinkKey = Menu.AddKeyOption( {"Utility", "TrickMyBlink"}, "Blink Key", Enum.ButtonCode.KEY_TAB)
TrickMyBlink.BlinkSlot = Menu.AddOption( {"Utility", "TrickMyBlink"}, "Blink Slot Num", "", 1, 6, 1)
TrickMyBlink.sleepers = {}
TrickMyBlink.BlinkInPack = false

function TrickMyBlink.OnUpdate()
    local hero = Heroes.GetLocal()
	local player = Players.GetLocal()
	if not hero or not Menu.IsEnabled(TrickMyBlink.IsToggled) or not Entity.IsAlive(hero) then return end
	if not Menu.IsKeyDown(TrickMyBlink.BlinkKey) or not TrickMyBlink.SleepCheck(0.05, "updaterate") then return end
	local blink = NPC.GetItem(hero, "item_blink", false)
	if not blink then return end
	if Ability.IsReady(blink) then
		TrickMyBlink.UseBlink(hero, blink) 
	end
	if Menu.IsEnabled(TrickMyBlink.IsBlinkAbuse) then
		if Ability.GetCooldownTimeLeft(blink) > 2 and Ability.GetCooldownTimeLeft(blink) < 6 then
			local entities = Heroes.GetAll()
			for index, ent in pairs(entities) do
				local enemyhero = Heroes.Get(index)
				if not Entity.IsSameTeam(hero, enemyhero) and NPC.IsEntityInRange(hero, enemyhero, NPC.GetAttackRange(enemyhero)) and NPC.IsAttacking(enemyhero) and NPC.HasInventorySlotFree(hero, false) and TrickMyBlink.SleepCheck(6, "backpack") then
					Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_ITEM, 8, Vector(0,0,0), blink, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, hero)
					Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_ITEM, Menu.GetValue(TrickMyBlink.BlinkSlot) - 1, Vector(0,0,0), blink, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, hero)
					TrickMyBlink.Sleep(6, "backpack")
					return
				end
			end
		end
	end
	TrickMyBlink.Sleep(0.05, "updaterate");
end

function TrickMyBlink.UseBlink(hero, blink)
	local castRange = Ability.GetLevelSpecialValueFor(blink, "blink_range") + NPC.GetCastRangeBonus(hero)
	local heroPosition = NPC.GetAbsOrigin(hero)
	local distance = TrickMyBlink.InFront(hero, heroPosition, castRange) - heroPosition

	distance:SetZ(0)
	distance:Normalize()
	distance:Scale(castRange - 1)

	local blinkpos = heroPosition + distance
	Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, hero, blinkpos, blink, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, hero, false, false)
end

function TrickMyBlink.InFront(hero, heroPosition, castRange)
	local vec = Entity.GetRotation(hero):GetVectors()
	if vec then
		local x = heroPosition:GetX() + vec:GetX() * castRange
		local y = heroPosition:GetY() + vec:GetY() * castRange
		return Vector(x,y,0)
	end
end

function TrickMyBlink.SleepCheck(delay, id)
	if not TrickMyBlink.sleepers[id] or (os.clock() - TrickMyBlink.sleepers[id]) > delay then
		return true
	end
	return false
end

function TrickMyBlink.Sleep(delay, id)
	if not TrickMyBlink.sleepers[id] or TrickMyBlink.sleepers[id] < os.clock() + delay then
		TrickMyBlink.sleepers[id] = os.clock() + delay
	end
end

return TrickMyBlink