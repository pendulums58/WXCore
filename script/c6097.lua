-- WXEX1-63 天驚の轟拳
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜乗機＞のシグニ１体をバニッシュする。そうした場合、対象の対戦相手のパワー12000以下のシグニ１体をバニッシュする。
-- ②あなたのドライブ状態の＜乗機＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキから＜乗機＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    e:SetLabel(m)
    if m==0 then
      Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_JOUKI),tp,LOCATION_SZONE,0,1,1,nil)
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
    else
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) and x:IsDrive() end,tp,LOCATION_SZONE,0,1,1,nil)
    end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local my,opp
      for tc in Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e):Iter() do
        if tc:GetControler()==tp then my=tc else opp=tc end
      end
      if my and Duel.Banish(my)>0 and opp then Duel.Banish(opp) end
    else
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) and Duel.Banish(tc)>0 then
        aux.SearchDeck(tp,aux.ClassFilter(0,RACE_JOUKI),1)
      end
    end
  end)
  c:RegisterEffect(e1)
end
