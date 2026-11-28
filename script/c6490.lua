-- WXK04-034 幻水姫　クロコワニ
-- 【自】：このシグニがアタックしたとき、あなたの手札から＜水獣＞のシグニを好きな枚数公開する。この方法でシグニを３枚以上公開した場合、【エナチャージ１】をする。５枚以上公開した場合、代わりに【エナチャージ２】をする。
-- 【出】《緑》《緑》：あなたのデッキの上からカードを２枚見る。その中から１枚を手札に加え、残りをエナゾーンに置く。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー10000以上のシグニ１体を対象とし、それをバニッシュする。②あなたのエナゾーンからカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local g=aux.RevealFromHand(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end)
    local n=g:GetCount()
    if n>=5 then Duel.EnaCharge(tp,2) elseif n>=3 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{G}{G}")
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToHand(Duel.SelectCards(tp,g,1,1))
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToEna(rest) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then
      local x=Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,1,1,nil):GetFirst()
      if x then Duel.SendToHand(x) end
      return
    end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
