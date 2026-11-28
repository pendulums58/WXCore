-- WXK08-024 コードＶＬ　える
-- 【常】：あなたの場に他の＜電機＞のシグニがあるかぎり、このシグニは対戦相手の効果によって、手札に戻らずダウンしない。
-- 【自】：各ターン終了時、対戦相手のシグニゾーンからカード１枚を対象とし、それを手札に戻してもよい。
-- ライフバースト：あなたのデッキから＜電機＞のシグニ１枚を探して公開し手札に加えるか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_BOUNCE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x~=h end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  c:RegisterEffect(e1)
  local e11=Effect.CreateEffect(c)
  e11:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e11:SetCode(EFFECT_NO_DOWN_BY_OPP)
  e11:SetRange(LOCATION_SZONE)
  e11:SetCondition(function(e) local h=e:GetHandler() return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x~=h end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  c:RegisterEffect(e11)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.SelectYesNo(tp) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,1):GetFirst()
    if x then
      if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(x) else Duel.PutOnField(x,tp) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e9)
end
