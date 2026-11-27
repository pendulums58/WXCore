-- WX10-002 エルドラ×マークＩＶＳＵＰＥＲ
-- 【常】：あなたの手札が５枚以上あるかぎり、あなたの＜水獣＞のシグニのパワーを＋2000する。
-- 【自】：このルリグがアタックしたとき、手札を１枚捨ててもよい。そうした場合、対戦相手のライフクロスの一番上を見る。その後、それをトラッシュに置いて対戦相手のデッキの一番上のカードをライフクロスに加えてもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end)(x) end)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_HAND,0,nil):GetCount()>=5 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    if aux.Discard(tp,1)==0 then return end
    local top=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil):GetFirst()
    if not top then return end
    Duel.ConfirmCards(tp,top)
    if Duel.SelectYesNo(tp) and Duel.SendToTrash(top,REASON_EFFECT)>0 then
      local d=Duel.GetDecktopGroup(1-tp,1)
      if d:GetCount()>0 then Duel.SendToLife(d) end
    end
  end)
  c:RegisterEffect(e2)
end
