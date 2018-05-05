--射鹰的月兔 清兰
function c11200081.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11200081,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCountLimit(2,11200081)
	e1:SetTarget(c11200081.sptg)
	e1:SetOperation(c11200081.spop)
	c:RegisterEffect(e1)
	
end
function c11200081.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c11200081.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and not c:IsType(TYPE_PENDULUM)
end
function c11200081.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)==1 then
			local t1=(Duel.GetMatchingGroupCount(c11200081.posfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)>0)
			local t2=c11200081.fusiontg(e,tp,eg,ep,ev,re,r,rp,c)
			if (t1 or t2) and c:IsReleasableByEffect() and Duel.SelectYesNo(tp,aux.Stringid(11200081,1)) then
				Duel.BreakEffect()
				Duel.Release(c,REASON_EFFECT)
				local m={}
				local n={}
				local ct=1
				if t1 then m[ct]=aux.Stringid(11200081,2) n[ct]=1 ct=ct+1 end
				if t2 then m[ct]=aux.Stringid(11200081,3) n[ct]=2 ct=ct+1 end
				local sp=Duel.SelectOption(tp,table.unpack(m))
				op=n[sp+1]
				if op==1 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
					local g=Duel.SelectMatchingCard(tp,c11200081.posfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
					Duel.ChangePosition(g,POS_FACEDOWN)
				elseif op==2 then
					c11200081.fusionop(e,tp,eg,ep,ev,re,r,rp)
				end
			end
		end
	end
end
function c11200081.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function c11200081.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x131) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c11200081.fusiontg(e,tp,eg,ep,ev,re,r,rp,c)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp)
	mg1:RemoveCard(c)
	local res=Duel.IsExistingMatchingCard(c11200081.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(c11200081.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	return res
end
function c11200081.fusionop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c11200081.filter1,nil,e)
	local sg1=Duel.GetMatchingGroup(c11200081.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c11200081.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
