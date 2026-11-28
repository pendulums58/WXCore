-- WXK06-031 幻竜姫　ファブニル
-- 【出】《黒》：対戦相手のシグニ１体を対象とし、あなたのデッキからレベル１、レベル２、レベル３、レベル４の黒のシグニを１枚ずつ探してトラッシュに置き、デッキをシャッフルする。この方法でカードを４枚トラッシュに置いた場合、それをバニッシュする。
-- 【起】《黒》場にあるこのシグニをゲームから除外する：あなたのトラッシュからすべての黒のカードをデッキに加えてシャッフルする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Group.CreateGroup()
    for lv=1,4 do
      local x=aux.Search(tp,function(y) return y:IsSigni() and y:IsColor(COLOR_BLACK) and y:GetLevel()==lv and not g:IsContains(y) end,1):GetFirst()
      if x then g:AddCard(x) end
    end
    local n=g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT) or 0
    aux.ShuffleDeck(tp)
    local tc=Duel.GetFirstTarget()
    if n==4 and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{B}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.Exclude(e:GetHandler())
  end)
  e2:SetOperation(function(e,tp,eg)
    Duel.SendToDeckShuffle(Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,nil),tp)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-10000)
    end
  end)
  c:RegisterEffect(e9)
end
