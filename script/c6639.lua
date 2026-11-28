-- WXK06-024 ＧＦ　最初の朝
-- 【常】：あなたの他のシグニのパワーは対戦相手の効果によって－（マイナス）されない。
-- 【自】：このシグニがアタックしたとき、そのアタックがこのターン四度目であなたのセンタールリグが＜エマ＞の場合、以下の３つから１つを選ぶ。
-- ①あなたのトラッシュからシグニ１枚を対象とし、それを場に出す。②対戦相手のシグニを２体まで対象とし、それらを手札に戻す。③カードを３枚引き、【エナチャージ３】をする。
-- ライフバースト：あなたのトラッシュから白のカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_OPP_POWER_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x~=e:GetHandler() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCondition(function(e,tp) return Duel.GetAttackCount()==4 and (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_EMMA) end)() end)
  e2:SetOperation(function(e,tp,eg)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    if m==0 then
      local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.PutOnField(x,tp) end
    elseif m==1 then
      local g=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
    else
      Duel.Draw(tp,3)
      Duel.EnaCharge(tp,3)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsColor(COLOR_WHITE) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e9)
end
