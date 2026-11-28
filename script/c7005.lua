-- WXK10-031 讃の宙遊　チキュウゴマ
-- 【自】：このシグニがアタックしたとき、《無》を支払ってもよい。そうした場合、あなたのデッキの上からシグニがめくれるまで公開する。その後、そのシグニより低いレベルを持つ対戦相手のシグニ１体を対象とし、それを手札に戻し、公開したカードをトラッシュに置く。
-- 【出】：数字１つを宣言する。あなたのデッキの一番上を公開し、それが宣言した数字と同じレベルを持つシグニの場合、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{C}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{C}"),REASON_COST)
    local total=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    local seen,sig=Group.CreateGroup(),nil
    for i=1,total do
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
      if last:IsSigni() then sig=last break end
    end
    if seen:GetCount()==0 then return end
    Duel.RevealCards(seen)
    if sig then
      local lv=sig:GetLevel()
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.SendToHand(tc) end
    end
    Duel.SendToTrash(seen,REASON_EFFECT)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local n=Duel.AnnounceNumber(tp,0,5)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:GetLevel()==n then Duel.SendToEna(x) end
  end)
  c:RegisterEffect(e2)
end
