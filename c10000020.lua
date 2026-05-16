-- Slifer the Sky Dragon
function c10000020.initial_effect(c)
	-- Requires 3 Tributes to Normal Summon/Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000020.sumcon)
	e1:SetOperation(c10000020.sumop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000020.sumcon)
	e2:SetOperation(c10000020.sumop)
	c:RegisterEffect(e2)

	-- Your opponent cannot Tribute this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(c10000020.recon)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
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
	e6:SetValue(c10000020.efilter)
	c:RegisterEffect(e6)

	-- Cannot be destroyed by battle with a monster with lower Divine Hierarchy
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e7:SetValue(c10000020.batfilter)
	c:RegisterEffect(e7)

	-- Controller takes no battle damage from that battle
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e8:SetValue(c10000020.batfilter)
	c:RegisterEffect(e8)

	-- If Special Summoned, return to location it was Special Summoned from during End Phase
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	e9:SetOperation(c10000020.retreg)
	c:RegisterEffect(e9)

	-- Other cards' effects are only applied on this card for 1 turn (Reset at End Phase)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_PHASE+PHASE_END)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1)
	e10:SetOperation(c10000020.resetop)
	c:RegisterEffect(e10)

	-- While face-up on the field, this card is also treated as a Dragon monster
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCode(EFFECT_ADD_RACE)
	e11:SetValue(RACE_DRAGON)
	c:RegisterEffect(e11)

	-- The original ATK/DEF of this card each become equal to the number of cards in your hand x 1000
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e12:SetRange(LOCATION_MZONE)
	e12:SetCode(EFFECT_SET_BASE_ATTACK)
	e12:SetValue(c10000020.adval)
	c:RegisterEffect(e12)
	local e13=e12:Clone()
	e13:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e13)

	-- If a monster is Summoned to opponent's field in face-up Position, while this card can attack...
	local e14=Effect.CreateEffect(c)
	e14:SetDescription(aux.Stringid(10000020,0))
	e14:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
	e14:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e14:SetCode(EVENT_SUMMON_SUCCESS)
	e14:SetRange(LOCATION_MZONE)
	e14:SetCondition(c10000020.atkcon)
	e14:SetTarget(c10000020.atktg)
	e14:SetOperation(c10000020.atkop)
	c:RegisterEffect(e14)
	local e15=e14:Clone()
	e15:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e15)
	local e16=e14:Clone()
	e16:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e16)
end

-- Divine Hierarchy System
function c10000020.get_hierarchy(c)
    if c:IsCode(10000000) or c:IsCode(10000020) then return 1 end -- Obelisk & Slifer
    if c:IsCode(10000010) then return 2 end -- Ra
    if c:IsCode(10000040) then return 3 end -- Horakhty (if applicable)
    return 0 -- Everything else
end

-- Checks if the monster is physically able to declare an attack
function c10000020.can_attack(c)
	return c:IsAttackPos() and not c:IsHasEffect(EFFECT_CANNOT_ATTACK) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
end

function c10000020.recon(e,c)
	return c:GetControler()~=e:GetHandler():GetControler()
end

function c10000020.sumcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-3 and Duel.GetTributeCount(c)>=3
end

function c10000020.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end

function c10000020.efilter(e,te)
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
		return c10000020.get_hierarchy(tc) < c10000020.get_hierarchy(c)
	end
	return false
end

function c10000020.batfilter(e,c)
	return c10000020.get_hierarchy(c) < c10000020.get_hierarchy(e:GetHandler())
end

-- Return to previous location logic
function c10000020.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=c:GetPreviousLocation()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(aux.Stringid(10000020,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetLabel(loc)
	e1:SetOperation(c10000020.retop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end

function c10000020.retop(e,tp,eg,ep,ev,re,r,rp)
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
function c10000020.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(c10000020.adval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	c:RegisterEffect(e2)
end

-- Hand x 1000 function
function c10000020.adval(e,c)
	local handler = e:GetHandler()
	return Duel.GetFieldGroupCount(handler:GetControler(),LOCATION_HAND,0)*1000
end

-- Thunder Force conditions
function c10000020.atkfilter(c,e,tp)
	return c:IsControler(1-tp) and c:IsFaceup() and (not e or c:IsRelateToEffect(e))
end

function c10000020.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c10000020.atkfilter,1,nil,nil,tp) and c10000020.can_attack(c)
end

function c10000020.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetTargetCard(eg)
end

function c10000020.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c10000020.can_attack(c) then return end

	local g=eg:Filter(c10000020.atkfilter,nil,e,tp)
	local dg=Group.CreateGroup()
	local tc=g:GetFirst()

	while tc do
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetAttack()==0 then dg:AddCard(tc) end
		elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetDefense()==0 then dg:AddCard(tc) end
		end
		tc=g:GetNext()
	end

	if dg:GetCount()>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
