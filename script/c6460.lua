-- WXK04-004 爪牙　遊月・肆戒
-- 【自】：このルリグのアタックが【ガード】されたとき、【エナチャージ１】をする。
-- 【出】《緑》：あなたのデッキの上からカードを５枚見る。その中から＜水獣＞のシグニを２枚まで公開し手札に加え、残りをシャッフルしてデッキの一番下に置く。
-- 【起】《ゲーム１回》バーニング《コインアイコン》：このターン、あなたが自分の効果によって手札から＜水獣＞のシグニを１枚以上公開したとき、対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_GUARDED)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{G}")
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,nil),0,2)
    if x:GetCount()>0 then Duel.RevealCards(x) Duel.SendToHand(x) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp,eg)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_REVEALED_FROM_HAND)
    e1:SetCondition(function(e2,tp2,eg,ep,ev,re,r,rp) if not (ep==tp and rp==tp) then return false end for x in eg:Iter() do if (function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end)(x) then return true end end return false end)
    e1:SetOperation(function()
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.SendToEna(tc) end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
