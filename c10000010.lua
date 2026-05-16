-- The Winged Dragon of Ra (Anime Version)
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

	-- Control of this card cannot switch
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e5)

	-- Unaffected by Spell/Trap effects that would make this card leave the field
	-- Unaffected by other monsters' effects, except for same/higher Divine Hierarchy (2)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetValue(c10000010.efilter)
	c:RegisterEffect(e6)

	-- Cannot be destroyed by battle with a monster with lower Divine Hierarchy
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e7:SetValue(c10000010.batfilter)
	c:RegisterEffect(e7)

	-- Controller takes no battle damage from that battle
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e8:SetCondition(c10000010.damcon)
	e8:SetOperation(c10000010.damop)
	c:RegisterEffect(e8)

	-- If Special Summoned, return to location it was Special Summoned from during End Phase
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	e9:SetOperation(c10000010.retreg)
	c:RegisterEffect(e9)

	-- Other cards' effects are only applied on this card for 1 turn (Reset at End Phase)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_PHASE+PHASE_END)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1)
	e10:SetOperation(c10000010.resetop)
	c:RegisterEffect(e10)

	-- ATK/DEF become total ATK/DEF of Tributed monsters
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetCode(EFFECT_MATERIAL_CHECK)
	e11:SetValue(c10000010.valcheck)
	c:RegisterEffect(e11)
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e12:SetCode(EVENT_SUMMON_SUCCESS)
	e12:SetOperation(c10000010.atkdefop)
	c:RegisterEffect(e12)

	-- Special Summoned: unaffected by attack prevention, attacks cannot be negated
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_SINGLE)
	e13:SetCode(EFFECT_IMMUNE_EFFECT)
	e13:SetRange(LOCATION_MZONE)
	e13:SetCondition(c10000010.sscon)
	e13:SetValue(c10000010.atkimmfilter)
	c:RegisterEffect(e13)
	local e14=Effect.CreateEffect(c)
	e14:SetType(EFFECT_TYPE_SINGLE)
	e14:SetCode(EFFECT_CANNOT_DISABLE_ATTACK)
	e14:SetCondition(c10000010.sscon)
	c:RegisterEffect(e14)

	-- If Special Summoned from GY: Apply 1 of these effects
	local e15=Effect.CreateEffect(c)
	e15:SetDescription(aux.Stringid(10000010,0))
	e15:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e15:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e15:SetCode(EVENT_SPSUMMON_SUCCESS)
	e15:SetCondition(c10000010.gycon)
	e15:SetTarget(c10000010.gytg)
	e15:SetOperation(c10000010.gyop)
	c:RegisterEffect(e15)
end

-- Divine Hierarchy System (Ra is 2)
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
	if Duel.GetTurnPlayer()~=tp then return false end
	local ph=Duel.GetCurrentPhase()
	local is_phase = (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE_END))
	if not is_phase then return false end
	return c:IsFaceup() and c:IsAttackPos() and c:CanAttack()
end

function c10000010.sumlimit(e,c)
	if not c then return false end
	return c:GetControler()~=e:GetHandlerPlayer()
end

function c10000010.nonsumlimit(e,re,rp)
	local tp=e:GetHandlerPlayer()
	local p=rp
	if Duel.GetCurrentChain()>0 then
		p=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_PLAYER)
	elseif not p or p==50 then
		p=Duel.GetTurnPlayer()
	end
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
		return bit.band(cat,CATEGORY_DESTROY)~=0 or bit.band(cat,CATEGORY_REMOVE)~=0
			or bit.band(cat,CATEGORY_TOHAND)~=0 or bit.band(cat,CATEGORY_TODECK)~=0
			or bit.band(cat,CATEGORY_TOGRAVE)~=0
	elseif te:IsActiveType(TYPE_MONSTER) then
		return c10000010.get_hierarchy(tc) < c10000010.get_hierarchy(c)
	end
	return false
end

function c10000010.batfilter(e,c)
	if not c then return false end
	return c10000010.get_hierarchy(c) < c10000010.get_hierarchy(e:GetHandler())
end

function c10000010.damcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return ep==tp and bc and c10000010.get_hierarchy(bc) < c10000010.get_hierarchy(e:GetHandler())
end

function c10000010.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,0)
end

function c10000010.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=c:GetPreviousLocation()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(aux.Stringid(10000010,1))
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

-- Tributed Stat Absorption
function c10000010.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	local def=0
	local tc=g:GetFirst()
	while tc do
		local catk=tc:GetPreviousAttackOnField()
		local cdef=tc:GetPreviousDefenseOnField()
		if catk<0 then catk=0 end
		if cdef<0 then cdef=0 end
		atk=atk+catk
		def=def+cdef
		tc=g:GetNext()
	end
	c:RegisterFlagEffect(10000010,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1,atk)
	c:RegisterFlagEffect(10000011,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1,def)
end

function c10000010.atkdefop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=c:GetFlagEffectLabel(10000010)
	local def=c:GetFlagEffectLabel(10000011)
	if atk and def then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end

-- SS Immunity
function c10000010.sscon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

function c10000010.atkimmfilter(e,te)
	return te:GetCode()==EFFECT_CANNOT_ATTACK
end

-- GY Effect Choice
function c10000010.gycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end

function c10000010.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=Duel.SelectOption(tp,aux.Stringid(10000010,2),aux.Stringid(10000010,3))
	e:SetLabel(op)
end

function c10000010.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local op=e:GetLabel()

	if op==0 then
		-- Point-to-Point Transfer
		local lp=Duel.GetLP(tp)
		if lp>1 then
			Duel.PayLPCost(tp,lp-1)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(lp-1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			c:RegisterEffect(e2)

			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_ADD_TYPE)
			e3:SetValue(TYPE_FUSION)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e3)

			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_ATTACK_ALL)
			e4:SetValue(1)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e4)

			-- Attack directly if no monsters (standard mechanic handled via engine logic)
			local e4b=Effect.CreateEffect(c)
			e4b:SetType(EFFECT_TYPE_SINGLE)
			e4b:SetCode(EFFECT_DIRECT_ATTACK)
			e4b:SetCondition(c10000010.dircon)
			e4b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e4b)

			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e5:SetCode(EVENT_RECOVER)
			e5:SetRange(LOCATION_MZONE)
			e5:SetOperation(c10000010.lpatkop)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e5)

			local e6=Effect.CreateEffect(c)
			e6:SetDescription(aux.Stringid(10000010,4))
			e6:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
			e6:SetType(EFFECT_TYPE_QUICK_O)
			e6:SetCode(EVENT_FREE_CHAIN)
			e6:SetRange(LOCATION_MZONE)
			e6:SetCost(c10000010.tribcost)
			e6:SetOperation(c10000010.tribop)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e6)

			local e7=Effect.CreateEffect(c)
			e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e7:SetCode(EVENT_CHAIN_SOLVING)
			e7:SetRange(LOCATION_MZONE)
			e7:SetCondition(c10000010.dfcon)
			e7:SetOperation(c10000010.dfop)
			e7:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e7)
		end
	else
		-- God Phoenix
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		c:RegisterEffect(e2)

		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c10000010.gpfilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)

		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e4)

		local e5=Effect.CreateEffect(c)
		e5:SetDescription(aux.Stringid(10000010,5))
		e5:SetCategory(CATEGORY_TOGRAVE)
		e5:SetType(EFFECT_TYPE_QUICK_O)
		e5:SetCode(EVENT_FREE_CHAIN)
		e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e5:SetRange(LOCATION_MZONE)
		e5:SetCondition(c10000010.gpcon)
		e5:SetCost(c10000010.gpcost)
		e5:SetTarget(c10000010.gptg)
		e5:SetOperation(c10000010.gpop)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e5)
	end
end

-- Point-to-Point Mechanics
function c10000010.dircon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==0
end

function c10000010.lpatkop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then
		Duel.SetLP(tp,Duel.GetLP(tp)-ev)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end

function c10000010.tribcost(e,tp,eg,ep,ev,re,r,rp,chk)
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
	e:GetHandler():RegisterFlagEffect(10000012,RESET_EVENT+RESETS_STANDARD,0,1,def)
	Duel.Release(g,REASON_COST)
end

function c10000010.tribop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=e:GetLabel()
		local def=c:GetFlagEffectLabel(10000012)
		if not def then def=0 end

		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end

function c10000010.dfcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:GetHandler():IsCode(95286165) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(e:GetHandler())
end

function c10000010.dfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeChainOperation(ev,c10000010.dfrepop)
end

function c10000010.dfrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
		Duel.Recover(tc:GetControler(),atk,REASON_EFFECT)
	end
end

-- God Phoenix Mechanics
function c10000010.gpfilter(e,te)
	local cat=te:GetCategory()
	return bit.band(cat,CATEGORY_DESTROY)~=0 or bit.band(cat,CATEGORY_REMOVE)~=0
		or bit.band(cat,CATEGORY_TOHAND)~=0 or bit.band(cat,CATEGORY_TODECK)~=0
		or bit.band(cat,CATEGORY_TOGRAVE)~=0 or bit.band(cat,CATEGORY_CONTROL)~=0
end

function c10000010.gpcon(e,tp,eg,ep,ev,re,r,rp)
	return c10000010.can_attack(e:GetHandler())
end

function c10000010.gpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end

function c10000010.gptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end

function c10000010.gpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
