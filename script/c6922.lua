-- WXK09-049 コードアート　Ａ・Ｃ・Ｓ
-- 【自】：あなたが《改造素材》１枚を使用したとき、あなたのデッキから＜電機＞のシグニ１枚を探してエナゾーンに置き、デッキをシャッフルする。
-- 【起】《ダウン》：あなたのトラッシュから＜電機＞のシグニ１枚を対象とし、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CUSTOM+6974)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,1):GetFirst()
    if x then Duel.SendToEna(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.SelfDownCost)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToEna(tc)
    end
  end)
  c:RegisterEffect(e2)
end
