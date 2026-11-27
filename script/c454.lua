-- WX05-012 フォーチューン・ファイブ
-- あなたのデッキの上からカードを５枚公開する。その中のそれぞれ名前の異なる＜原子＞のシグニの枚数を数える。その後、それが３枚以上の場合、対戦相手のシグニ１体を対象とし、それをダウンし凍結する。それが４枚以上の場合、カードを１枚引く。それが５枚の場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。その後、公開したカードを好きな順番でデッキの一番下に置く。（条件を満たした効果をすべて行える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local seen,n={},0
    for x in g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,nil):Iter() do
      if not seen[x:GetCode()] then
        seen[x:GetCode()]=true
        n=n+1
      end
    end
    -- 조건을 채운 것을 모두(차례로)
    if n>=3 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then
        Duel.Down(tc)
        Duel.Freeze(tc)
      end
    end
    if n>=4 then Duel.Draw(tp,1) end
    if n>=5 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
    g=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if g:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,g),false) end
  end)
  c:RegisterEffect(e1)
end
