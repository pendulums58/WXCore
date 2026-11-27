-- WX22-017 パープル・スプラッシュ
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。
-- ②あなたのトラッシュからレベル２以下の黒のシグニを２枚まで対象とし、それらを手札に加える。
-- ③各プレイヤーは自分のデッキの上から、自分のセンタールリグのレベル１につきカードを３枚トラッシュに置く。
-- ④対戦相手のシグニ１体を対象とし、あなたのトラッシュにカードが２５枚以上ある場合、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then aux.AddPower(e,tc,-8000) end end
    if m&2~=0 then local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) and x:GetLevel()<=2 end,tp,LOCATION_TRASH,0,0,2,nil) if g:GetCount()>0 then Duel.SendToHand(g) end end
    if m&4~=0 then for p=0,1 do local lc=Duel.GetMatchingGroup(nil,p,LOCATION_LRIG,0,nil):GetFirst() local g=Duel.GetDecktopGroup(p,3*(lc and lc:GetLevel() or 0)) if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end end end
    if m&8~=0 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc and Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()>=25 then Duel.SendToTrash(tc,REASON_EFFECT) end end
  end)
  c:RegisterEffect(e1)
end
