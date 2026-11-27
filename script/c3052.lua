-- WX19-025 大罠　ドッキリ
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを３枚見る。その中から《トラップアイコン》を持つカード１枚をチェックゾーンに置き、残りを好きな順番でデッキの一番下に置く。その後、この方法でチェックゾーンに置いたカードの《トラップアイコン》を発動させる。（その後そのカードをトラッシュに置く）
-- 【トラップアイコン】：あなたのデッキの上からカードを２枚エナゾーンに置く。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(Card.HasTrapIcon,nil),0,1):GetFirst()
    local rest=g:Filter(function(c) return c~=x end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
    -- 「チェックゾーンに置き《トラップアイコン》を発動」: 【トラップ】으로 설치해 바로 발동하는 것으로 근사
    if x and Duel.SetTrap(x,tp) then Duel.OpenTrap(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e3)
end
