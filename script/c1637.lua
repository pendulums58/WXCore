-- WDK07-Y11 羅植　アネモネ
-- 【自】：このシグニがバニッシュされたとき、手札から＜植物＞のシグニを１枚捨ててもよい。そうした場合、あなたのデッキの一番上を公開する。それが＜植物＞のシグニの場合、それを場に出す。
-- 【自】：このシグニが開花したとき、以下の２つから１つを選ぶ。
-- ①カードを１枚引き、【エナチャージ１】をする。
-- ②対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンする。カードを１枚引く。
local s,id=GetID()
s.shoku=aux.ClassFilter(0,RACE_SHOKUBUTSU)  -- ＜植物＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    local g=Duel.SelectDiscard(tp,0,1,s.shoku)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)==0 then return end
    -- ＜植物＞가 아니면 뒷면으로 덱 위에(FAQ 2)
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top then return end
    Duel.RevealCards(top)
    if s.shoku(top) then Duel.PutOnField(top,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BLOOM)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
    if e:GetLabel()==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      Duel.Draw(tp,1)
      Duel.EnaCharge(tp,1)
      return
    end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
