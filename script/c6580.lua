-- WXK05-038 紅蓮の使い魔　マールト
-- 【出】手札から＜紅蓮＞か＜古代兵器＞のシグニを１枚捨てる：あなたのデッキからこの方法で捨てたシグニと同じレベルの、＜紅蓮＞か＜古代兵器＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local lv=-1
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GUREN) or x:IsClass(0,RACE_KODAIHEIKI)) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return h:GetCount()>0 end
    local x=Duel.SelectCards(tp,h,1,1):GetFirst()
    lv=x:GetLevel()
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_GUREN) or x:IsClass(0,RACE_KODAIHEIKI)) end)(x) and x:GetLevel()==lv end,1)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
