-- WXK10-032 密英の暗号　カルダン
-- 【自】：このシグニがアタックしたとき、このシグニを場からトラッシュに置いてもよい。そうした場合、あなたの手札から＜英知＞のシグニ１枚を場に出す。そのシグニの【出】能力は発動しない。
-- 【出】《白》《白》《無》：あなたのデッキからレベルの異なる＜英知＞のシグニ２枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：あなたのデッキから白のカード１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 then Duel.PutOnField(Duel.SelectCards(tp,g,1,1):GetFirst(),tp,true) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{W}{W}{C}")
  e2:SetOperation(function(e,tp,eg)
    local a=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end,1):GetFirst()
    if a then
      local lv=a:GetLevel()
      local b=aux.Search(tp,function(y) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)(y) and y:GetLevel()~=lv and y~=a end,1):GetFirst()
      local g=Group.CreateGroup()
      g:AddCard(a)
      if b then g:AddCard(b) end
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return x:IsColor(COLOR_WHITE) end,1)
  end)
  c:RegisterEffect(e9)
end
