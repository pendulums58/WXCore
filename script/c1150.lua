-- WD06-018 ＰＬＵＳ　ＲＵＳＨ
-- 対戦相手のライフクロスの一番上を見る。あなたはそれをトラッシュに置いてもよい。そうした場合、対戦相手はデッキの一番上のカードをライフクロスに加える。
-- あなたはカードを１枚引く。
-- ライフバースト：あなたのデッキから【ライフバースト】を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsLifeBurst() end,1)
  end)
  c:RegisterEffect(e2)
end
-- 보는 것은 쓴 사람만(FAQ 1). 라이프 클로스가 없어도 뽑는다(FAQ 2)
function s.op(e,tp)
  local g=Duel.GetLifetopGroup(1-tp,1)
  if g:GetCount()>0 then
    Duel.ConfirmCards(tp,g)
    if Duel.SelectYesNo(tp) and Duel.SendToTrash(g,REASON_EFFECT)>0 then
      Duel.SendToLife(Duel.GetDecktopGroup(1-tp,1))
    end
  end
  Duel.Draw(tp,1)
end
