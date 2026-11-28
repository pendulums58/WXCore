-- WXK07-051 羅星　ゴーストジュピタ
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、「【自】：このシグニがアタックしたとき、正面のシグニ１体を対象とし、あなたのデッキの上からカードを３枚公開する。ターン終了時まで、それのパワーをこの方法で公開されたシグニのレベルの合計１につき－1000する。公開したカードをシャッフルしてデッキの一番下に置く。」を得る。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,2))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    local tc=e:GetHandler():GetFrontCard()
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local n=0
    for y in g:Iter() do if y:IsSigni() then n=n+y:GetLevel() end end
    if tc and tc:IsLocation(LOCATION_SZONE) and n>0 then aux.AddPower(e,tc,-1000*n) end
    Duel.SendToDeckBottom(g,true)
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then aux.AddPower(e,tc,-3000) end
  end)
  c:RegisterEffect(e9)
end
