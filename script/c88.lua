-- WX16-Re18 レゾナンス・マーチ
-- あなたのルリグデッキからレゾナを２枚まで出現条件を無視して場に出す。この方法で場に出たレゾナの【出】能力は発動しない。
-- ターン終了時、それらをルリグデッキに戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) end,tp,LOCATION_LDECK,0,nil),0,2)
    local out=Group.CreateGroup()
    for x in g:Iter() do if Duel.PutOnField(x,tp,true) then out:AddCard(x) end end
    if out:GetCount()==0 then return end
    -- 「ターン終了時、それらをルリグデッキに戻す」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TURN_END)
    e1:SetOperation(function()
      local back=out:Filter(function(x) return x:IsLocation(LOCATION_SZONE) end,nil)
      if back:GetCount()>0 then Duel.SendToLrigDeck(back) end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
