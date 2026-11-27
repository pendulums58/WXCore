-- WX19-062 幻水　キンギョ
-- 【自】：このシグニがアタックしたとき、カード名１つを宣言する。対戦相手はデッキの一番上を公開する。それが宣言したカードの場合、それをトラッシュに置き、あなたのデッキの一番上のカードをエナゾーンに置くかカードを１枚引く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local cid=Duel.AnnounceCard(tp)
    local x=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    if x:IsCardName(cid) then
      Duel.SendToTrash(x,REASON_EFFECT)
      if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,1) else Duel.Draw(tp,1) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
