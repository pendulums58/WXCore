-- WXK10-086 魏軍の剛毅　ウキン
-- 【出】：あなたのデッキから＜武勇＞のシグニを１枚まで探してトラッシュに置き、デッキをシャッフルする。
-- 【起】《ターン１回》《黒》：あなたのトラッシュからレベル２以下の＜武勇＞のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BUYU) end,1):GetFirst()
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{B}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_BUYU) end)(x) and x:GetLevel()<=2 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.PutOnField(tc,tp)
    end
  end)
  c:RegisterEffect(e2)
end
