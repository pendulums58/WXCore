-- PR-K070 札探の蒼天　メイ（カードゲーマーvol.49 付録）
-- 【出】エナゾーンからカード１枚をトラッシュに置く：あなたのデッキから、この方法でトラッシュに置いたカードと共通するクラスを持つ無色ではないレベル３以下のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《ターン１回》《青×0》：対戦相手は手札を公開する。対戦相手はあなたのルリグデッキからカード１枚を見ないで選び、あなたはそれを公開する。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil)
    if chk==0 then return g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    s.cls=x:GetClasses()
    Duel.SendToTrash(x,REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    local cls=s.cls or {}
    local g=aux.Search(tp,function(x)
      if not x:IsSigni() or x:GetColor()==0 or x:GetLevel()>3 then return false end
      for _,a in ipairs(x:GetClasses()) do for _,b in ipairs(cls) do if a==b then return true end end end
      return false
    end,1)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()>0 then Duel.RevealCards(h) end
    local ld=Duel.GetMatchingGroup(nil,tp,LOCATION_LDECK,0,nil)
    local x=ld:GetCount()>0 and Duel.SelectCards(1-tp,ld,1,1):GetFirst()
    if x then Duel.RevealCards(Group.CreateGroup(x)) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
