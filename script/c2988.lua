-- WX18-034 コードオーダー　モツナ
-- 【常】：このシグニはアクセされているかぎり、対戦相手のルリグの効果を受けない。
-- 【出】：あなたのデッキの上からカードを３枚公開する。その中から《アクセアイコン》を持つすべてのシグニをエナゾーンに置き、残りをトラッシュに置く。
-- 【起】《緑》《緑》《緑》：ターン終了時まで、あなたのすべての＜調理＞のシグニは【ランサー】を得る。
-- ライフバースト：【エナチャージ２】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsAcce() end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_LRIG) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local a=g:Filter(function(x) return x:IsSigni() and x:HasAcceIcon() end,nil)
    if a:GetCount()>0 then Duel.SendToEna(a) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{G}{G}{G}")
  e3:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.GrantKeyword(e,tc,EFFECT_LANCER) end  -- [まで]
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,2)
  end)
  c:RegisterEffect(e4)
end
