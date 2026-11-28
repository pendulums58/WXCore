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
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.a,s.b,s.c=nil,nil,nil
    if m==1 then
      s.a=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    elseif m==2 then
      local f=function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end
      s.a=Duel.SelectTarget(tp,f,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
      s.b=Duel.SelectTarget(tp,f,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
      s.c=Duel.SelectTarget(tp,f,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then local g=Duel.GetDecktopGroup(tp,6) if g:GetCount()>0 then Duel.SendToEna(g) end return end
    if m==1 then
      if s.a and s.a:IsRelateToEffect(e) then Duel.Banish(s.a) end
      if s.b and s.b:IsRelateToEffect(e) then Duel.Down(s.b) end
      Duel.Draw(tp,1)
      return
    end
    if s.a and s.a:IsRelateToEffect(e) then aux.AddPower(e,s.a,5000) end  -- [まで]
    if s.b and s.b:IsRelateToEffect(e) then aux.GrantKeyword(e,s.b,EFFECT_LANCER) end  -- [まで]
    if s.c and s.c:IsRelateToEffect(e) then aux.GrantKeyword(e,s.c,EFFECT_DOUBLE_CRUSH) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
