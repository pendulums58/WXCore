-- WXK01-060 幻怪　アルラウネ
-- 【出】：以下の２つから１つを選ぶ。
-- ①このターン、あなたが次に緑のアーツを使用する場合、それの使用コストは《無×1》減る。
-- ②このシグニと隣接するあなたのシグニを２体まで対象とし、ターン終了時まで、それらのパワーをそれぞれ＋3000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
      -- [の間] 「このターン、次に」 줄었는지와 상관없이 다음 1장(FAQ 2)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e2,x) return x:IsType(TYPE_ARTS) and x:IsColor(COLOR_GREEN) end)
      e1:SetValue("{C}")
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
      return
    end
    -- 자신은 아니다(FAQ 4)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x~=h and h:IsAdjacent(x) end,tp,LOCATION_SZONE,0,0,2,nil)
    for x in g:Iter() do aux.AddPower(e,x,3000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
