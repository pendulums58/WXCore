-- WX07-037 轟砲　マスケッタ
-- 《クロスアイコン》《弩砲　ファイヤレイジ》の右
-- 【クロス出】：以下の２つから１つを選ぶ。
-- ①ターン終了時まで、このシグニの基本パワーは15000になる。
-- ②対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2195,CROSS_RIGHT)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=5000 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local h=e:GetHandler()
      if not h:IsLocation(LOCATION_SZONE) then return end
      -- [まで] ターン終了時まで
      local e1=Effect.CreateEffect(h)
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_SET_BASE_POWER)
      e1:SetValue(15000)
      e1:SetReset(RESET_PHASE+PHASE_END)
      h:RegisterEffect(e1)
    else
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
