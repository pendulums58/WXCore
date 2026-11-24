-- WDK01-008 火旗相当
-- 以下の２つから１つを選ぶ。
-- ①ターン終了時まで、対象のあなたのセンタールリグ１体は対象のあなたの＜乗機＞のシグニ１体に乗る。（すでに他のシグニに乗っている場合は乗り換える）
-- ②あなたのデッキの上からカードを５枚見る。その中から＜乗機＞のシグニを３枚まで公開し手札に加える。残りをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
s.jouki=aux.ClassFilter(0,RACE_JOUKI)  -- ＜乗機＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,s.jouki,tp,LOCATION_SZONE,0,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Ride(tc) end
      return
    end
    local _,rest=aux.ExcavateToHand(tp,5,s.jouki,0,3,true)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
end
