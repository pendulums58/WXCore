-- WX16-Re20 グレイブ・ラッシュ
-- あなたのライフクロスが２枚以下の場合、このアーツは追加で《アタックフェイズアイコン》を持つ。
-- あなたのトラッシュからシグニ３枚を対象とし、あなたの場にシグニがない場合、それらを能力を持たないシグニとして場に出す。ターン終了時、それらを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「ライフクロスが２枚以下なら《アタックフェイズアイコン》」는 아직(근사)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,3,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()>0 then return end
    local out=Group.CreateGroup()
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) and Duel.PutOnField(x,tp) then
        out:AddCard(x)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LOSE_ABILITY)
        x:RegisterEffect(e1)
      end
    end
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_TURN_END)
    e2:SetOperation(function()
      local g=out:Filter(function(x) return x:IsLocation(LOCATION_SZONE) end,nil)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
  end)
  c:RegisterEffect(e1)
end
