-- WX09-053 多幸
-- ターン終了時まで、あなたのすべてのシグニのパワーを＋5000する。あなたの場に緑のシグニが３体あり、それらが共通するクラスを持つ場合、ターン終了時まで、それらは追加で「【自】：このシグニがアタックしたとき、あなたのデッキの一番上のカードをエナゾーンに置く。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [まで] 처리할 때 장에 있는 시그니
    local share=(function() local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end,tp,LOCATION_SZONE,0,nil) return g:GetCount()==3 and aux.ShareClass(g) end)()
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      aux.AddPower(e,tc,5000)
      if share then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
        e1:SetCode(EVENT_ATTACK)
        e1:SetOperation(function(e2,tp2) Duel.EnaCharge(tp2,1) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:GrantEffect(e1)
      end
    end
  end)
  c:RegisterEffect(e1)
end
