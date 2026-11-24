-- WD23-023-E 幻水　キス
-- 【自】《ターン１回》：あなたか対戦相手のライフクロス１枚がトラッシュに置かれたとき、カードを１枚引く。
-- 【出】：このシグニが効果によって場に出たとき、対戦相手はライフクロス１枚をトラッシュに置く。それが《ライフバースト》を持っていた場合、対戦相手はデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：あなたのライフクロス１枚をトラッシュに置く。そうした場合、あなたのデッキからカード１枚を探してライフクロスに加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- 리프레시로 놓인 것도(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():IsPreviousLocation(LOCATION_LIFE) end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r) return (r&REASON_EFFECT)~=0 end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetLifetopGroup(1-tp,1):GetFirst()
    if not tc or Duel.SendToTrash(tc,REASON_EFFECT)==0 then return end
    if tc:IsLifeBurst() then Duel.SendToLife(Duel.GetDecktopGroup(1-tp,1)) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetLifetopGroup(tp,1)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT)==0 then return end
    local tc=aux.Search(tp,nil,1):GetFirst()
    if tc then Duel.SendToLife(tc) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
