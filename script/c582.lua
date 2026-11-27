-- WX14-028 羅植華姫　バオバブーン
-- 【出】：あなたのデッキから緑ではないレベル５のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》手札にあるこのカードをゲームから除外する：あなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：あなたのデッキから異なる色を持つカード２枚を探してエナゾーンに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and not x:IsColor(COLOR_GREEN) and x:GetLevel()==5 end,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_HAND)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_HAND) end
    Duel.Exclude(e:GetHandler())
  end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
    Duel.SetSelectCheck(function(g)
      if g:GetCount()==0 then return true end
      local a,b
      for x in g:Iter() do if a then b=x else a=x end end
      return g:GetCount()==2 and a:GetColor()~=b:GetColor()
    end)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil),0,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
