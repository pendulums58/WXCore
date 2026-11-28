-- WXK10-003 焼風水月
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手は手札を１枚捨てる。
-- ②対戦相手のシグニ１体を対象とし、それをダウンする。
-- ③対戦相手のパワー12000以下のシグニ１体を対象とし、あなたの場にあるシグニの数が対戦相手より２体以上少ない場合、それをバニッシュする。
-- ④あなたのライフクロスが対戦相手より２枚以上少ない場合、対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do
      if m==0 then
        aux.Discard(1-tp,1)
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if not tc then return end
        Duel.Down(tc)
      elseif m==2 then
        local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if not tc then return end
        if Duel.GetMatchingGroup(Card.IsSigni,1-tp,LOCATION_SZONE,0,nil):GetCount()-Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()>=2 then Duel.Banish(tc) end
      elseif m==3 then
        if Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil):GetCount()-Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()>=2 then Duel.Crush(1-tp,1) end
      end
    end
  end)
  c:RegisterEffect(e1)
end
