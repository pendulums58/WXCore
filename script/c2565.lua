-- WX12-039 彷徨変異の小悪　サユラギ
-- 【自】：このシグニがアタックしたとき、各プレイヤーは自分のデッキの上からカードを３枚トラッシュに置く。
-- 【出】：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをすべてのプレイヤーのトラッシュにあるカード４枚につき－1000する。
-- ライフバースト：あなたのセンタールリグが＜アルフォウ＞の場合、各プレイヤーは自分のデッキの上からカードを１０枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    for _,p in ipairs({tp,1-tp}) do local g=Duel.GetDecktopGroup(p,3) if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-1000*math.floor((Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()+Duel.GetMatchingGroup(nil,1-tp,LOCATION_TRASH,0,nil):GetCount())/4)) end
  end)  -- [まで]
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    if not (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_ALFOU) end)() then return end
    for _,p in ipairs({tp,1-tp}) do local g=Duel.GetDecktopGroup(p,10) if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end end
  end)
  c:RegisterEffect(e3)
end
