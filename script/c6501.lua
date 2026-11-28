-- WXK04-045 紅蓮の使い魔　モルモー
-- 【出】：あなたのデッキの上からカードを４枚見る。その後、その中からあなたの場にあるこのシグニ以外の、対象の＜紅蓮＞か＜古代兵器＞のシグニ１体と同じ名前のシグニ１枚を公開し手札に加え、残りをシャッフルしてデッキの一番下に置く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x~=e:GetHandler() and (x:IsClass(0,RACE_GUREN) or x:IsClass(0,RACE_KODAIHEIKI)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local x=Duel.SelectCards(tp,g:Filter(function(y) return y:IsSigni() and y:IsSameName(tc) end,nil),0,1)
      if x:GetCount()>0 then Duel.RevealCards(x) Duel.SendToHand(x) end
    end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
