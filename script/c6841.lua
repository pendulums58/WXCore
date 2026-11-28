-- WXK08-055 ダーク・フラッシュ
-- あなたのシグニの下にあるカードを好きな枚数対象とし、それらをトラッシュに置く。その後、この方法でカードを１枚以上トラッシュに置いた場合、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。２枚以上置いた場合、追加でカードを１枚引く。３枚以上置いた場合、追加で対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。４枚以上置いた場合、追加であなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local pool=(function() local g=Group.CreateGroup() for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do for y in x:GetUnderGroup():Iter() do g:AddCard(y) end end return g end)()
    local sg=pool:GetCount()>0 and Duel.SelectCards(tp,pool,0,pool:GetCount()) or Group.CreateGroup()
    local n=sg:GetCount()>0 and Duel.SendToTrash(sg,REASON_EFFECT) or 0
    if n>=1 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,-5000) end
    end
    if n>=2 then Duel.Draw(tp,1) end
    if n>=3 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,-10000) end
    end
    if n>=4 then
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if tc then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-10000)
    end
  end)
  c:RegisterEffect(e9)
end
