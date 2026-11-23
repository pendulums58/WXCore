-- WD09-013 羅星　デネブ
-- 【出】：数字１つを宣言する。その後、あなたのデッキの一番上を公開し、それが宣言した数字と同じレベルを持つシグニである場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 시그니 레벨은 0~5. 맞지 않으면 다시 뒷면으로 덱 위에 둔다(FAQ 1)
function s.op(e,tp)
  local n=Duel.AnnounceNumber(tp,0,5)
  local g=Duel.GetDecktopGroup(tp,1)
  local tc=g:GetFirst()
  if not tc then return end
  Duel.RevealCards(g)
  if tc:IsSigni() and tc:GetLevel()==n then Duel.SendToHand(tc) end
end
