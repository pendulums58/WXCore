-- WX06-016 聖墓の神姉　ムンカルン
-- 【常】：このシグニのパワーはあなたの場にある他の＜天使＞のシグニ１体につき＋1000される。
-- 【自】：対戦相手の効果によってこのシグニが場を離れたとき、あなたのデッキからレベル３以下の＜天使＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- ライフバースト：あなたのデッキからそれぞれ同じレベルの＜天使＞のシグニ２枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 1000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,e:GetHandler()):GetCount() end)
  c:RegisterEffect(e1)
  -- 상대의 효과로(룰 처리·배틀은 아니다. FAQ 1~3)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_EFFECT~=0 and rp~=tp end)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(c) and c:IsLevelBetween(0,3) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  -- 같은 레벨 2장이 아니면 하나도(FAQ 5)
  e3:SetOperation(function(e,tp)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
    Duel.SetSelectCheck(function(g)
      if g:GetCount()==0 then return true end
      if g:GetCount()~=2 then return false end
      local lv
      for x in g:Iter() do
        if lv and x:GetLevel()~=lv then return false end
        lv=x:GetLevel()
      end
      return true
    end)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_MDECK,0,nil),0,2)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
