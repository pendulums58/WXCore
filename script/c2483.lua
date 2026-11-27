-- WX11-032 羅植姫　スノロップ
-- 【常】：このシグニはあなたのエナゾーンにあるカードの色を追加で持つ。
-- 【常】：このシグニのパワーは自身が持つ色の種類１つにつき＋4000され、このシグニは自身と共通する色を持つ対戦相手のシグニの効果を受けない。
-- 【自】：対戦相手のターン終了時、このシグニのパワーが20000で、あなたのライフクロスが２枚以下の場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：あなたのトラッシュからカードを２枚まで対象とし、それらをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 장에서만 에나의 색을 더 가진다(FAQ 3). 무색은 색이 아니다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ADD_COLOR)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e)
    local v=0
    for x in Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_ENA,0,nil):Iter() do v=v|x:GetColor() end
    return v
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetValue(function(e) local h,n=e:GetHandler(),0 for _,col in ipairs({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}) do if h:IsColor(col) then n=n+1 end end return 4000*n end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EFFECT_IMMUNE)
  e3:SetRange(LOCATION_SZONE)
  e3:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() and sc:GetColor()&e:GetHandler():GetColor()~=0 end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e4:SetDescription(aux.Ability(id,2))
  e4:SetCode(EVENT_TURN_END)
  e4:SetRange(LOCATION_SZONE)
  e4:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp and e:GetHandler():GetPower()==20000 and Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=2 end)
  e4:SetOperation(function(e,tp)
    local d=Duel.GetDecktopGroup(tp,1)
    if d:GetCount()>0 then Duel.SendToLife(d) end
  end)
  c:RegisterEffect(e4)
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_LIFEBURST)
  e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e5:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e5)
end
