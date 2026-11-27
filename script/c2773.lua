-- WX15-054 四英の掛算　#マルチプ#
-- 【常】：あなたのセンタールリグが緑で、このシグニが中央のシグニゾーンにあるかぎり、このシグニは「【自】：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、あなたのデッキの上からカードを２枚エナゾーンに置く。」を得る。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 조건을 만족하는 동안 얻는다
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_CRUSHED)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  g:SetOperation(function(e,tp) local d=Duel.GetDecktopGroup(tp,2) if d:GetCount()>0 then Duel.SendToEna(d) end end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() local lc=Duel.GetMatchingGroup(nil,h:GetControler(),LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsColor(COLOR_GREEN) and h:IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
