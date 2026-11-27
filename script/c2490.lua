-- WX11-041 羅石　オロオラ
-- 《クロスアイコン》《羅石　ロズオラ》の左
-- 【出】：あなたのデッキの上からカードを２枚トラッシュに置く。この方法で＜鉱石＞か＜宝石＞のシグニが合計２枚トラッシュに置かれた場合、カードを１枚引く。
-- 【クロス自】：このシグニが《ヘブン》したとき、パワーが「あなたのトラッシュにある＜鉱石＞と＜宝石＞のシグニを合わせた枚数×1000」以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：どちらか1つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2512,CROSS_LEFT)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end)(x) end,nil):GetCount()>=2 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_HEAVEN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=1000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end,tp,LOCATION_TRASH,0,nil):GetCount()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=n end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
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
