-- WXK09-097 楽隊の童話　ドッグメ
-- 【出】：あなたのターンの場合、あなたのデッキの上からカードを３枚トラッシュに置く。その後、この方法でトラッシュに置かれたカードがすべて黒の場合、《黒》を支払ってもよい。そうした場合、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 뒷부분(대상 상대 시그니 －)은 근사: －5000
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetTurnPlayer()~=tp then return end
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    for x in g:Iter() do if not x:IsColor(COLOR_BLACK) then return end end
    if not (Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then aux.AddPower(e,tc,-5000) end
  end)
  c:RegisterEffect(e1)
end
