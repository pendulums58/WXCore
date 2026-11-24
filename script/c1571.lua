-- WDK01-001 レイラ＝フルスロットル
-- 【ライド】
-- 【出】《赤》：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《コインアイコン》：あなたのデッキから＜乗機＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
s.jouki=aux.ClassFilter(0,RACE_JOUKI)  -- ＜乗機＞のシグニ
function s.initial_effect(c)
  aux.AddRide(c,aux.Ability(id,0))
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCoinCost(1)
  -- 찾지 않아도 된다(FAQ 6). 빈 존이 없으면 내지 못한다(FAQ 7)
  e2:SetOperation(function(e,tp)
    local tc=aux.Search(tp,s.jouki,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
