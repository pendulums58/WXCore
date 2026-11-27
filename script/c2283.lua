-- WX08-037 羅石　ムンスト
-- 《クロスアイコン》《羅石　サンスト》の左
-- 【クロス出】：以下の２つから１つを選ぶ。
-- ①対戦相手のパワー3000以下のすべてのシグニをバニッシュする。
-- ②ターン終了時まで、このシグニの基本パワーは15000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2270,CROSS_LEFT)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()<=3000 end,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.Banish(g) end
      return
    end
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_POWER)
    e1:SetValue(15000)
    e1:SetReset(RESET_PHASE+PHASE_END)
    h:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
