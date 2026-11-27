-- WX01-030 贖罪の対火
-- 対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。ターン終了時まで、あなたのセンタールリグは【ダブルクラッシュ】を得る。
-- ライフバースト：あなたのライフクロス１枚をトラッシュに置く。そうした場合、対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(aux.BanishPowerTarget(12000))
  -- 바니시하지 못해도 【ダブルクラッシュ】는 얻는다(FAQ 2·5·6)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:GetPower()<=12000 then Duel.Banish(tc) end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if lc then aux.GrantKeyword(e,lc,EFFECT_DOUBLE_CRUSH) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  -- 1장을 놓지 못하면 크러시하지 않는다(FAQ 4)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetLifetopGroup(tp,1)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT)==0 then return end
    Duel.Crush(1-tp,1)
  end)
  c:RegisterEffect(e2)
end
