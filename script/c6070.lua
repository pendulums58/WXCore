-- WXEX1-36 羅星姫　ヒミコ
-- 【自】：このシグニがアタックしたとき、手札から＜宇宙＞のシグニを１枚捨ててもよい。その後、この方法で捨てたシグニと同じレベルの対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【出】《赤》《無》：あなたのデッキからレベルの合計が８になるように＜宇宙＞のシグニを３枚まで探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：あなたのデッキの一番上を公開する。その後、それがレベル４のシグニの場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local pool=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_UCHU),tp,LOCATION_HAND,0,nil)
    if pool:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local d=Duel.SelectDiscard(tp,1,1,aux.ClassFilter(0,RACE_UCHU)):GetFirst()
    if not d then return end
    local lv=aux.RefLevel(tp,d)
    if Duel.SendToTrash(d,REASON_DISCARD+REASON_EFFECT)>0 then
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{R}{C}")
  e2:SetOperation(function(e,tp)
    local d=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil)
    Duel.ConfirmCards(tp,d)
    Duel.SetSelectCheck(function(g)
      if g:GetCount()==0 then return true end
      local sum=0
      for x in g:Iter() do sum=sum+x:GetLevel() end
      return sum==8
    end)
    local pick=Duel.SelectCards(tp,d:Filter(aux.ClassFilter(0,RACE_UCHU),nil),0,3)
    if pick:GetCount()>0 then Duel.RevealCards(pick) Duel.SendToHand(pick) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:IsLevelBetween(4,4) then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e9)
end
