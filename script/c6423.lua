-- WXK03-049 讃の遊　ゴムショット
-- 【出】：あなたのデッキから＜遊具＞のシグニ１枚を探してもよい。そうした場合、デッキをシャッフルし、そのシグニを公開しデッキの上から一番目かニ番目に置く。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    -- 찾지 않으면 섞지 않는다(FAQ 1)
    local x=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) end,1):GetFirst()
    if not x then return end
    aux.ShuffleDeck(tp)
    Duel.RevealCards(x)
    Duel.SendToDeckPosition(x,Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
