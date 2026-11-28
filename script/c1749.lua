-- WDK13-017 羅星 モンキーネ
-- 【自】：このシグニがアタックしたとき、あなたのデッキを上からシグニが２枚めくれるまで公開してもよい。その後、それらのレベルの合計が６以上の場合、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－1000する。公開したカードをトラッシュに置く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  -- 공개한 카드를 먼저 트래시에 두고, 룰 처리 바니시는 그 뒤(FAQ 1)
  e1:SetOperation(function(e,tp)
    if not Duel.SelectYesNo(tp) then return end
    local n,g,k=0,nil,0
    repeat
      n=n+1
      g=Duel.GetDecktopGroup(tp,n)
      k=g:Filter(Card.IsSigni,nil):GetCount()
    until k>=2 or g:GetCount()<n
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local lv=0
    for x in g:Iter() do if x:IsSigni() then lv=lv+x:GetLevel() end end
    if lv>=6 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,-1000) end  -- [まで] ターン終了時まで
    end
    Duel.SendToTrash(g,REASON_EFFECT)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
