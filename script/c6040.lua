-- WXEX1-06 炎・花代・肆
-- 【出】：あなたのデッキからカード名に《フレイスロ》を含むシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《コインアイコン》《コインアイコン》：あなたのデッキの上からカードを５枚公開する。その中からシグニ１枚を手札に加え、残りをシャッフルしてデッキの一番下に置く。その後、この方法でカード名に《フレイスロ》を含むカードが３枚以上公開された場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,2)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetCoinCost(2)
  e2:SetOperation(function(e,tp)
    local n=aux.RevealCount(tp,5)
    local g=Duel.GetDecktopGroup(tp,n)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local fcnt=g:Filter(function(x) return aux.NameHas(x,"フレイスロ") end,nil):GetCount()
    local pick=Duel.SelectCards(tp,g:Filter(Card.IsSigni,nil),1,1)
    if pick:GetCount()>0 then Duel.SendToHand(pick) end
    local rest=g:Filter(function(x) return not pick:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
    if fcnt>=3 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e2)
end
