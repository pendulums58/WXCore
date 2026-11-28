-- WXK03-053 大装　コンゴウショ
-- 【常】：このターンにあなたが手札を３枚以上捨てていた場合、このシグニは【アサシン】を得る。
-- （【アサシン】を持つシグニがアタックすると正面のシグニとバトルをせず対戦相手にダメージを与える）
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 나오기 전에 버린 것도(FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetDiscardedCount(e:GetHandlerPlayer())>=3 end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
