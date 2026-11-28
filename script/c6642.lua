-- WXK06-027 コードラビリンス　ヨグ＝ソトース
-- 【自】：このシグニがアタックしたとき、このターンに対戦相手のカードがあなたの効果によって１枚以上デッキに移動していた場合、以下の３つから１つを選ぶ。３枚以上移動していた場合、代わりに２つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをバニッシュする。②対戦相手は手札を１枚捨てる。③カードを２枚引く。
-- ライフバースト：あなたのトラッシュから＜迷宮＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(function(e,tp) return Duel.GetDeckMovedCount(tp)>=1 end)
  e1:SetOperation(function(e,tp,eg)
    local mx=Duel.GetDeckMovedCount(tp)>=3 and 2 or 1
    for _,m in ipairs(Duel.SelectModes(tp,1,mx,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
      if m==0 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.Banish(tc) end
      elseif m==1 then aux.Discard(1-tp,1)
      else Duel.Draw(tp,2) end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_MEIKYU) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
