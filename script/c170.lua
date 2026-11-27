-- WX09-CB02 終末の回旋　チェロン
-- 【常】：あなたの《クロスアイコン》を持つ＜美巧＞のシグニは対戦相手の効果によってバニッシュされない。
-- 【自】：このシグニがバニッシュされたとき、《緑》を支払ってもよい。そうした場合、あなたのデッキからレベル３以下の《終末の回旋　チェロン》以外の＜美巧＞のシグニ１枚を探して公開し手札に加えるか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_BANISH_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) and x:HasCrossIcon() end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    local x=aux.Search(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(c) and c:GetLevel()<=3 and not c:IsCardName(id) end,1):GetFirst()
    if x then
      Duel.RevealCards(x)
      -- 예 = 장에 낸다, 아니오 = 패에 넣는다
      if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
