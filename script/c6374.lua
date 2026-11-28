-- WXK02-098 串刺し公　ヴラド
-- 【出】：あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたの＜武勇＞のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法でトラッシュに置かれた黒のカード１枚につき＋2000する。
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
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BUYU) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if tc and n>0 then aux.AddPower(e,tc,2000*n) end
  end)
  c:RegisterEffect(e1)
end
