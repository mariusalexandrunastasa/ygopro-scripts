-- The Winged Dragon of Ra
function c10000010.initial_effect(c)
	c:SetUniqueOnField(1,0,10000010)

	-- Requires 3 Tributes to Normal Summon/Set
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000010.sumcon)
	e1:SetOperation(c10000010.sumop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000010.sumcon)
	e2:SetOperation(c10000010.sumop)
	c:RegisterEffect(e2)

	-- Your opponent cannot Tribute this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(c10000010.sumlimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e4:SetValue(c10000010.nonsumlimit)
	c:RegisterEffect(e4)

	-- Summon Cannot be Negated
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e5)

	-- Control of this card cannot switch
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e6)

	-- Unaffected by Spell/Trap effects that would make this card leave the field
	-- Unaffected by other monsters' effects, except for higher Divine Hierarchy
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetValue(c10000010.efilter)
	c:RegisterEffect(e7)

	-- Cannot be destroyed by battle with a monster with lower Divine Hierarchy
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e8:SetValue(c10000010.batfilter)
	c:RegisterEffect(e8)

	-- Controller takes no battle damage from that battle
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e9:SetValue(c10000010.batfilter)
	c:RegisterEffect(e9)

	-- If Special Summoned, return to location it was Special Summoned from during End Phase
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e10:SetCode(EVENT_SPSUMMON_SUCCESS)
	e10:SetOperation(c10000010.retreg)
	c:RegisterEffect(e10)

	-- Other cards' effects are only applied on this card for 1 turn (Reset at End Phase)
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e11:SetCode(EVENT_PHASE+PHASE_END)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCountLimit(1)
	e11:SetOperation(c10000010.resetop)
	c:RegisterEffect(e11)

	-- One Turn Kill (Pay LP to gain ATK/DEF)
	local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(10000010,0))
	e12:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e12:SetType(EFFECT_TYPE_IGNITION)
	e12:SetRange(LOCATION_MZONE)
	e12:SetCost(c10000010.atkcost)
	e12:SetOperation(c10000010.atkop)
	c:RegisterEffect(e12)

	-- Point-to-Point Transfer (Tribute monsters to gain ATK/DEF)
	local e13=Effect.CreateEffect(c)
	e13:SetDescription(aux.Stringid(10000010,1))
	e13:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e13:SetType(EFFECT_TYPE_IGNITION)
	e13:SetRange(LOCATION_MZONE)
	e13:SetCost(c10000010.atkcost2)
	e13:SetOperation(c10000010.atkop2)
	c:RegisterEffect(e13)

	-- God Phoenix (Pay 1000 LP to destroy an opponent's monster)
	local e14=Effect.CreateEffect(c)
	e14:SetDescription(aux.Stringid(10000010,2))
	e14:SetCategory(CATEGORY_DESTROY)
	e14:SetType(EFFECT_TYPE_IGNITION)
	e14:SetRange(LOCATION_MZONE)
	e14:SetCost(c10000010.descost)
	e14:SetTarget(c10000010.destg)
	e14:SetOperation(c10000010.desop)
	c:RegisterEffect(e14)

	-- Direct Attack Capability
	local e15=Effect.CreateEffect(c)
	e15:SetType(EFFECT_TYPE_SINGLE)
	e15:SetCode(EFFECT_DIRECT_ATTACK)
	e15:SetCondition(c10000010.dircon)
	c:RegisterEffect(e15)
end

-- Divine Hierarchy System
function c10000010.get_hierarchy(c)
	if not c then return 0 end
	if c:IsCode(10000000) or c:IsCode(10000020) then return 1 end -- Obelisk & Slifer
	if c:IsCode(10000010) then return 2 end -- Ra
	if c:IsCode(10000040) then return 3 end -- Horakhty (if applicable)
	return 0 -- Everything else
end

-- Checks if the monster is physically able to declare an attack
function c10000010.can_attack(c)
	local tp=c:GetControler()
	-- Must be the controller's turn
	if Duel.GetTurnPlayer()~=tp then return false end
	-- Must be Main Phase 1, Main Phase 2, or during the Battle Phase
	local ph=Duel.GetCurrentPhase()
	local is_phase = (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
	if not is_phase then return false end
	-- Must be face-up attack position and physically capable of attacking
	return c:IsFaceup() and c:IsAttackPos() and not c:IsHasEffect(EFFECT_CANNOT_ATTACK) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
end

function c10000010.sumlimit(e,c)
	if not c then return false end
	return c:GetControler()~=e:GetHandlerPlayer()
end

function c10000010.nonsumlimit(e,re,rp)
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

function c10000010.sumcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-3 and Duel.GetTributeCount(c)>=3
end

function c10000010.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end

function c10000010.efilter(e,te)
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
		return c10000010.get_hierarchy(tc) < c10000010.get_hierarchy(c)
	end
	return false
end

function c10000010.batfilter(e,c)
	if not c then return false end
	return c10000010.get_hierarchy(c) < c10000010.get_hierarchy(e:GetHandler())
end

-- Return to previous location logic
function c10000010.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=c:GetPreviousLocation()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(aux.Stringid(10000010,3))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetLabel(loc)
	e1:SetOperation(c10000010.retop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end

function c10000010.retop(e,tp,eg,ep,ev,re,r,rp)
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
function c10000010.resetop(e,tp,eg,ep,ev,re,r,rp)
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

-- One Turn Kill Logic
function c10000010.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)>100 end
	local lp=Duel.GetLP(tp)
	e:SetLabel(lp-100)
	Duel.PayLPCost(tp,lp-100)
end

function c10000010.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=e:GetLabel()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end

-- Point-to-Point Transfer Logic
function c10000010.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
	local g=Duel.SelectReleaseGroup(tp,nil,1,99,e:GetHandler())
	local atk=0
	local def=0
	local tc=g:GetFirst()
	while tc do
		local catk=tc:GetAttack()
		local cdef=tc:GetDefense()
		if catk<0 then catk=0 end
		if cdef<0 then cdef=0 end
		atk=atk+catk
		def=def+cdef
		tc=g:GetNext()
	end
	e:SetLabel(atk)
	e:SetLabel(def)
	Duel.Release(g,REASON_COST)
end

function c10000010.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=e:GetLabel()
		local def=e:GetLabelObject()

		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(def)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end

-- God Phoenix Logic
function c10000010.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end

function c10000010.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function c10000010.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- Direct Attack Parameter
function c10000010.dircon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==0
end
