-- WX21-020 プライマル・サーガ
-- 以下の３つから１つを選ぶ。
-- ①あなたのデッキの上からカードを６枚エナゾーンに置く。
-- ②対象の対戦相手のシグニ１体をバニッシュし、対象の対戦相手のシグニ１体をダウンする。カードを１枚引く。
-- ③ターン終了時まで、対象のあなたの＜天使＞のシグニ１体のパワーを＋5000し、対象のあなたの＜天使＞のシグニ１体は【ランサー】を得、対象のあなたの＜天使＞のシグニ１体は【ダブルクラッシュ】を得る。（同じシグニを選ぶこともできる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1])
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then local g=Duel.GetDecktopGroup(tp,6) if g:GetCount()>0 then Duel.SendToEna(g) end return end
    if m==1 then
      local a=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      local b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if a then Duel.Banish(a) end
      if b and b:IsLocation(LOCATION_SZONE) then Duel.Down(b) end
      Duel.Draw(tp,1)
      return
    end
    local f=function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end
    local a=Duel.SelectTarget(tp,f,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if a then aux.AddPower(e,a,5000) end  -- [まで]
    local b=Duel.SelectCards(tp,Duel.GetMatchingGroup(f,tp,LOCATION_SZONE,0,nil),1,1):GetFirst()
    if b then aux.GrantKeyword(e,b,EFFECT_LANCER) end
    local c=Duel.SelectCards(tp,Duel.GetMatchingGroup(f,tp,LOCATION_SZONE,0,nil),1,1):GetFirst()
    if c then aux.GrantKeyword(e,c,EFFECT_DOUBLE_CRUSH) end
  end)
  c:RegisterEffect(e1)
end
