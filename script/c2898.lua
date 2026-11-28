-- WX17-004 落華流粋
-- 以下の４つから１つを選ぶ。あなたのセンタールリグが＜リル＞か＜メル＞の場合、代わりに２つまで選ぶ。
-- ①対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
-- ②対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。
-- ③あなたのシグニ１体を対象とし、ターン終了時まで、それは【ダブルクラッシュ】を得る。そのシグニがレベル４以上の場合、追加でそれは【アサシン】を得る。
-- ④あなたのデッキの一番上のカードをライフクロスに加える。手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- カーニバル †ＭＡＩＳ†のジョーカー: このゲームの間、使用コストは《黒×2》《無×1》(WXK03-002 FAQ 3)
  e1:SetMinCost(function(e,tp,base) if Duel.IsPlayerAffected(tp,1006456) then return "{B}{B}{C}" end return base end)
  e1:SetDeclare(function(e,tp)
    if Duel.IsPlayerAffected(tp,1006456) then Duel.SetUseCost("{B}{B}{C}") end
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,((function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and (lc:IsLrigType(LRIG_RIL) or lc:IsLrigType(LRIG_MEL)) end)()) and 2 or 1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if m&2~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if m&4~=0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
      if tc then aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH) if tc:GetLevel()>=4 then aux.GrantKeyword(e,tc,EFFECT_ASSASSIN) end end
    end
    if m&8~=0 then
      local x=Duel.GetDecktopGroup(tp,1):GetFirst()
      if x then Duel.SendToLife(x) end
      aux.Discard(tp,2)
    end
  end)
  c:RegisterEffect(e1)
end
