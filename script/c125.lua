-- WX15-Re15 コードアンチ　メイジ
-- 【起】《アタックフェイズアイコン》《黒》《黒》《無》：あなたのトラッシュからそれぞれレベルの異なる無色ではないシグニ４枚をデッキの一番下に置く。そうした場合、このシグニをトラッシュから場に出し、デッキをシャッフルする。（この能力は、このシグニがトラッシュにある場合にしか使用できない）
-- ライフバースト：あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュから無色ではないシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_TRASH)
  e1:SetEnaCost("{B}{B}{C}")
  e1:SetTiming(TIMING_ATTACK)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(function(sg) return sg:GetCount()==4 and aux.DistinctLevels(sg) end)
    local pick=Duel.SelectCards(tp,g,0,4)
    if pick:GetCount()<4 then return end
    Duel.SendToDeckBottom(pick,false)
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local x=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
end
