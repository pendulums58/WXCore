-- WXK07-028 羅菌姫　ウェディ
-- 【自】：あなたのアタックフェイズ開始時、あなたの場に【チャーム】が１枚以上ある場合、以下の３つから１つを選ぶ。３枚ある場合、代わりに２つまで選ぶ。
-- ①シグニ１体を対象とし、ターン終了時まで、それのパワーを＋3000し、それは【ランサー】を得る。
-- ②シグニ１体を対象とし、ターン終了時まで、それは「【常】：バニッシュされない。」を得る。
-- ③対戦相手のシグニ１体を対象とし、あなたの場に【チャーム】が３枚ある場合、それをバニッシュする。
-- ライフバースト：あなたのトラッシュから＜微菌＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and (function() local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)()>=1 end)
  e1:SetOperation(function(e,tp,eg)
    local n=(function() local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)()
    for _,m in ipairs(Duel.SelectModes(tp,1,n>=3 and 2 or 1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
      if m==0 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then aux.AddPower(e,tc,3000) aux.GrantKeyword(e,tc,EFFECT_LANCER) end
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then aux.GrantKeyword(e,tc,EFFECT_CANNOT_BANISH) end
      else
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc and (function() local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)()>=3 then Duel.Banish(tc) end
      end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKIN) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
