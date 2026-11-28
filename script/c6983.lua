-- WXK10-009 フォーチュン・イマジン
-- 以下の３つから１つを選ぶ。あなたのセンタールリグが＜リメンバ＞の場合、代わりに２つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをダウンし、対戦相手のすべてのシグニを凍結する。
-- ②あなたのデッキの一番下のカードをトラッシュに置く。それがシグニの場合、それをトラッシュから場に出す。
-- ③あなたのデッキの一番下のカードをトラッシュに置く。それがシグニの場合、それと同じレベルの対戦相手のすべてのシグニをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,1,((function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_REMEMBER) end)()) and 2 or 1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
      if m==0 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if not tc then return end
        Duel.Down(tc)
        local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
        if g:GetCount()>0 then Duel.Freeze(g) end
      elseif m==1 then
        local g=Duel.GetDeckbottomGroup(tp,1)
        local x=g:GetFirst()
        if not x then return end
        Duel.SendToTrash(g,REASON_EFFECT)
        if x:IsSigni() and x:IsLocation(LOCATION_TRASH) then Duel.PutOnField(x,tp) end
      elseif m==2 then
        local g=Duel.GetDeckbottomGroup(tp,1)
        local x=g:GetFirst()
        if not x then return end
        Duel.SendToTrash(g,REASON_EFFECT)
        if x:IsSigni() then
          local lv=x:GetLevel()
          local d2=Duel.GetMatchingGroup(function(y) return y:IsSigni() and y:GetLevel()==lv end,tp,0,LOCATION_SZONE,nil)
          if d2:GetCount()>0 then Duel.Down(d2) end
        end
      end
    end
  end)
  c:RegisterEffect(e1)
end
