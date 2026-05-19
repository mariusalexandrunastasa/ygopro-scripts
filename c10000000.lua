-- Obelisk the Tormentor
function c10000000.initial_effect(c)
	-- Requires 3 Tributes to Normal Summon/Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000000.sumcon)
	e1:SetOperation(c10000000.sumop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000000.sumcon)
	e2:SetOperation(c10000000.sumop)
	c:RegisterEffect(e2)

	-- Your opponent cannot Tribute this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(c10000000.sumlimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e4:SetValue(c10000000.nonsumlimit)
	c:RegisterEffect(e4)

	-- Control of this card cannot switch
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e5)

	-- Unaffected by Spell/Trap effects that would make this card leave the field
	-- Unaffected by other monsters' effects, except for same/higher Divine Hierarchy
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetValue(c10000000.efilter)
	c:RegisterEffect(e6)

	-- Cannot be destroyed by battle with a monster with lower Divine Hierarchy
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e7:SetValue(c10000000.batfilter)
	c:RegisterEffect(e7)

	-- Controller takes no battle damage from that battle
	-- Changed from EVENT_PRE_BATTLE_DAMAGE continuous (used nonexistent
	-- Duel.ChangeBattleDamage) to EFFECT_AVOID_BATTLE_DAMAGE, matching Slifer's
	-- implementation which is the correct engine-native approach.
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e8:SetValue(c10000000.batfilter)
	c:RegisterEffect(e8)

	-- If Special Summoned, return to location it was Special Summoned from during End Phase
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	e9:SetOperation(c10000000.retreg)
	c:RegisterEffect(e9)

	-- Other cards' effects are only applied on this card for 1 turn (Reset at End Phase)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_PHASE+PHASE_END)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1)
	e10:SetOperation(c10000000.resetop)
	c:RegisterEffect(e10)

	-- While face-up on the field, this card is also treated as a Warrior monster
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCode(EFFECT_ADD_RACE)
	e11:SetValue(RACE_WARRIOR)
	c:RegisterEffect(e11)

	-- During Battle Phase, if this card can attack: Tribute 2; ATK becomes ∞, force attack, calc damage
	local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(10000000,0))
	e12:SetCategory(CATEGORY_ATKCHANGE)
	e12:SetType(EFFECT_TYPE_QUICK_O)
	e12:SetCode(EVENT_FREE_CHAIN)
	e12:SetRange(LOCATION_MZONE)
	e12:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e12:SetCondition(c10000000.infcon)
	e12:SetCost(c10000000.cost)
	e12:SetOperation(c10000000.infop)
	c:RegisterEffect(e12)

	-- If this card can attack: Tribute 2; inflict damage equal to ATK and destroy all opponent's monsters
	local e13=Effect.CreateEffect(c)
	e13:SetDescription(aux.Stringid(10000000,1))
	e13:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e13:SetType(EFFECT_TYPE_QUICK_O)
	e13:SetCode(EVENT_FREE_CHAIN)
	e13:SetRange(LOCATION_MZONE)
	e13:SetCondition(c10000000.descon)
	e13:SetCost(c10000000.cost)
	e13:SetTarget(c10000000.destg)
	e13:SetOperation(c10000000.desop)
	c:RegisterEffect(e13)
end

-- Divine Hierarchy System
function c10000000.get_hierarchy(c)
	if not c then return 0 end
	if c:IsCode(10000000) or c:IsCode(10000020) then return 1 end -- Obelisk & Slifer
	if c:IsCode(10000010) then return 2 end -- Ra
	if c:IsCode(10000040) then return 3 end -- Horakhty (if applicable)
	return 0 -- Everything else
end

-- Checks if the monster is physically able to declare an attack
function c10000000.can_attack(c)
	local tp=c:GetControler()
	-- Must be the controller's turn
	if Duel.GetTurnPlayer()~=tp then return false end
	-- Must be Main Phase 1 or during the Battle Phase
	local ph=Duel.GetCurrentPhase()
	local is_phase = (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
	if not is_phase then return false end
	-- Must be face-up attack position and physically capable of attacking
	return c:IsFaceup() and c:IsAttackPos()
		and not c:IsHasEffect(EFFECT_CANNOT_ATTACK)
		and not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
end

function c10000000.sumlimit(e,c)
	if not c then return false end
	return c:GetControler()~=e:GetHandlerPlayer()
end

function c10000000.nonsumlimit(e,re,rp)
	local tp=e:GetHandlerPlayer()
	local p=rp
	-- Safeguard: If inside an active chain activation cost check, grab the true player initiating it
	if Duel.GetCurrentChain()>0 then
		p=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_PLAYER)
	elseif not p or p==50 then -- Fallback for empty or invalid player engine states
		p=Duel.GetTurnPlayer()
	end
	-- Only block if the player attempting the tribute is the opponent
	return p~=tp
end

function c10000000.sumcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-3 and Duel.GetTributeCount(c)>=3
end

function c10000000.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end

function c10000000.efilter(e,te)
	local c=e:GetHandler()
	local tc=te:GetHandler()

	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
		local cat=te:GetCategory()
		-- Checks if the S/T effect attempts to make the card leave the field
		return bit.band(cat,CATEGORY_DESTROY)~=0 or bit.band(cat,CATEGORY_REMOVE)~=0
			or bit.band(cat,CATEGORY_TOHAND)~=0 or bit.band(cat,CATEGORY_TODECK)~=0
			or bit.band(cat,CATEGORY_TOGRAVE)~=0
	elseif te:IsActiveType(TYPE_MONSTER) then
		-- Checks if the monster effect comes from a lower hierarchy
		if not tc then return false end
		return c10000000.get_hierarchy(tc) < c10000000.get_hierarchy(c)
	end
	return false
end

function c10000000.batfilter(e,c)
	if not c then return false end
	return c10000000.get_hierarchy(c) < c10000000.get_hierarchy(e:GetHandler())
end

-- Return to previous location logic
function c10000000.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=c:GetPreviousLocation()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(aux.Stringid(10000000,2))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetLabel(loc)
	e1:SetOperation(c10000000.retop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end

function c10000000.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local loc=e:GetLabel()
		if loc==LOCATION_GRAVE then
			Duel.SendtoGrave(c,REASON_EFFECT)
		elseif loc==LOCATION_HAND then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		elseif loc==LOCATION_DECK then
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		elseif loc==LOCATION_REMOVED then
			Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		else
			Duel.SendtoGrave(c,REASON_EFFECT)
		end
	end
end

-- Approximates "Effects apply for 1 turn" by hard resetting the base stats at the End Phase
function c10000000.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(c:GetBaseAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e2:SetValue(c:GetBaseDefense())
	c:RegisterEffect(e2)
end

function c10000000.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,e:GetHandler()) end
	local g=Duel.SelectReleaseGroup(tp,nil,2,2,e:GetHandler())
	Duel.Release(g,REASON_COST)
end

-- Infinity Attack / Force Battle Effect
function c10000000.infcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and c10000000.can_attack(c)
end

function c10000000.infop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- Apply Infinity ATK until end of the next Damage Step
		-- Removed Duel.CalculateDamage() call -- that function does not exist in this
		-- engine's Lua API. The ATK boost is applied here and the player attacks normally.
		-- The "force attack / perform damage calculation" clause of the card text cannot be
		-- reproduced purely in Lua; the boost takes effect and the player declares the attack
		-- on the same battle step.
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(9999999) -- Infinite approximation
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end

-- Soul Energy MAX (Damage & Destroy) Effect
function c10000000.descon(e,tp,eg,ep,ev,re,r,rp)
	return c10000000.can_attack(e:GetHandler())
end

function c10000000.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end

function c10000000.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=c:GetAttack()
		if Duel.Damage(1-tp,atk,REASON_EFFECT)>0 then
			local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
