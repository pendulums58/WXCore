-- PR-K056 メモリアル・ファイブ（カードゲーマーvol.47 付録）
-- 以下の５つから５つまで選ぶ。このアーツの使用コストは選んだ数だけ《青×1》増える。
-- ①対戦相手のレベル３以下のシグニ１体を対象とし、それをダウンする。
-- ②対戦相手のレベル４以上のシグニ１体を対象とし、それをダウンする。
-- ③対戦相手のすべてのシグニを凍結する。
-- ④対戦相手は手札を１枚捨てる。
-- ⑤カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local ms=Duel.SelectModes(tp,1,5,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))
    local b=0
    for _,m in ipairs(ms) do b=b|(1<<m) end
    e:SetLabel(b)
  end)
  -- 고른 수만큼 《青×1》 늘어난다
  aux.SetCostBy(e1,function(e,tp,base)
    local n,b=0,e:GetLabel()
    for i=0,4 do if b&(1<<i)~=0 then n=n+1 end end
    return base..string.rep("{U}",n)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local b=e:GetLabel()
    if b&1~=0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil) end
    if b&2~=0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()>=4 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local b=e:GetLabel()
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.Down(tc) end
    end
    if b&4~=0 then for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do Duel.Freeze(x) end end
    if b&8~=0 then aux.Discard(1-tp,1) end
    if b&16~=0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
