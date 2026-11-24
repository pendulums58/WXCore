-- WDK07-E01 エルドラ　ＴＹＰＥ×Ⅳ
-- 【デコレ】
-- 【出】：【エナチャージ１】をする。この方法で＜調理＞のシグニがエナゾーンに置かれた場合、カードを１枚引く。
-- 【起】《ターン１回》《コインアイコン》《コインアイコン》《コインアイコン》：手札から＜調理＞のシグニを１枚捨てる。そうした場合、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
s.chouri=aux.ClassFilter(0,RACE_CHOURI)  -- ＜調理＞のシグニ
function s.initial_effect(c)
  aux.AddDecore(c,aux.Ability(id,0))
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local x=Duel.EnaCharge(tp,1):GetFirst()
    if x and x:IsLocation(LOCATION_ENA) and s.chouri(x) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetCoinCost(3)
  e3:SetOperation(function(e,tp)
    -- 패는 비공개라 버리지 않아도 된다
    local g=Duel.SelectDiscard(tp,0,1,s.chouri)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)==0 then return end
    local top=Duel.GetDecktopGroup(tp,1)
    if top:GetCount()>0 then Duel.SendToLife(top) end
  end)
  c:RegisterEffect(e3)
end
