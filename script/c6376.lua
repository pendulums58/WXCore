-- WXK02-100 鳩の黒魔術　セミラミス
-- 【出】：あなたのデッキの上からカードを３枚トラッシュに置く。ターン終了時まで、このシグニのパワーをこの方法でトラッシュに置かれた黒のカード１枚につき＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=0
    for x in g:Iter() do if x:IsColor(COLOR_BLACK) and x:IsLocation(LOCATION_TRASH) then n=n+1 end end
    local h=e:GetHandler()
    if n>0 and h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,2000*n) end
  end)
  c:RegisterEffect(e1)
end
