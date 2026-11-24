-- WDK05-R07 イコール・プライズ
-- あなたの手札からそれぞれレベルの異なるシグニを３枚まで捨てる。その後、この方法で捨てたシグニ１枚につきそれと同じレベルを持つ対戦相手のシグニ１体を対象とし、それらをバニッシュする。（例えばレベル２とレベル３のシグニを捨てた場合レベル２のシグニ１体とレベル３のシグニ１体をバニッシュする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.SetSelectCheck(aux.DistinctLevels)
    local g=Duel.SelectDiscard(tp,0,3,Card.IsSigni)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)
    -- 버린 시그니의 레벨은 서로 다르다. 1~4로 칠 수 있는 카드는 남은 레벨에서 고른다(FAQ 4)
    local used,levels={},{}
    for x in g:Iter() do
      if not x:HasKeyword(EFFECT_ANY_LEVEL) then
        used[x:GetLevel()]=true
        levels[#levels+1]=x:GetLevel()
      end
    end
    for x in g:Iter() do
      if x:HasKeyword(EFFECT_ANY_LEVEL) then
        local lv
        repeat lv=aux.RefLevel(tp,x) until not used[lv]
        used[lv]=true
        levels[#levels+1]=lv
      end
    end
    local tg=Group.CreateGroup()
    for _,lv in ipairs(levels) do
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then tg:AddCard(tc) end
    end
    if tg:GetCount()>0 then Duel.Banish(tg) end
  end)
  c:RegisterEffect(e1)
end
