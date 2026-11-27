-- WX14-030 コードラブハート　†Ｍ・Ｃ・Ｍ・Ｒ†
-- 【起】《アタックフェイズアイコン》《スペルカットインアイコン》《黒×0》：あなたのトラッシュからそれぞれレベルの異なる無色ではないシグニ４枚をデッキに加えてシャッフルする。そうした場合、以下の３つから１つを選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ②スペル１つを対象とし、それの効果を打ち消す。
-- ③あなたのトラッシュからレベル４以下の＜電機＞のシグニ１枚を対象とし、それを場に出す。
-- ライフバースト：対戦相手のセンタールリグ１体を対象とし、それをダウンし凍結する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetTiming(TIMING_ATTACK+TIMING_CUTIN)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(function(sg)
      if sg:GetCount()~=4 then return false end
      local seen={}
      for x in sg:Iter() do
        if seen[x:GetLevel()] then return false end
        seen[x:GetLevel()]=true
      end
      return true
    end)
    local pick=Duel.SelectCards(tp,g,0,4)
    if pick:GetCount()<4 then return end
    Duel.SendToDeckShuffle(pick,tp)
    local m=Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1]
    if m==0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    elseif m==1 then
      Duel.NegateSpell()
    else
      local tc=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end)(x) and x:GetLevel()<=4 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if tc then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc)
        Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e2)
end
