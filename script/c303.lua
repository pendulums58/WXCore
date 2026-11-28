-- PR-476 クロス・テンスグロウ！（第6回大須星決定戦 景品）
-- あなたのセンタールリグのレベルが対戦相手より低い場合、あなたのセンタールリグをグロウしてもよい。この方法でグロウしたルリグの【出】能力は発動しない。その後、あなたのセンタールリグと同じレベルの対戦相手のルリグかシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 그로우 코스트는 낸다(FAQ 1): 코스트를 낼 수 있을 때만 효과로 그로우(코스트는 근사로 내지 않는다). 같은 레벨이면 그로우 없이 뒷부분만(FAQ 2)
  e1:SetOperation(function(e,tp)
    local lc,oc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst(),Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if lc and oc and lc:GetLevel()<oc:GetLevel() then
      local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) and x:GetLevel()==lc:GetLevel()+1 end,tp,LOCATION_LDECK,0,nil)
      local n=g:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SelectCards(tp,g,1,1):GetFirst()
      if n then Duel.GrowByEffect(n,tp,true) end
    end
    lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local lv=lc:GetLevel()
    local tc=Duel.SelectTarget(tp,function(x) return (x:IsSigni() or x:IsType(TYPE_LRIG)) and x:GetLevel()==lv end,tp,0,LOCATION_SZONE+LOCATION_LRIG,1,1,nil):GetFirst()
    if tc then aux.GrantKeyword(e,tc,EFFECT_CANNOT_ATTACK) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
