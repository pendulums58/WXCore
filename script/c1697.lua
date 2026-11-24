-- WDK10-009 魅惑の冥者　ハナレ
-- 【出】：あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。あなたのセンタールリグが＜ウリス＞の場合、追加で黒のシグニ１枚を対象とし、それを手札に加える。
-- 【起】《ターン１回》手札を１枚捨てる：対戦相手のシグニゾーン１つを指定する。次のあなたのターンまで、指定されたシグニゾーンにあるシグニのパワーをそのシグニのレベル１につき－2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 덱에서 놓은 뒤에 트래시 전체에서 고른다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
    if not (lc and lc:IsLrigType(LRIG_URITH)) then return end
    tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetCost(aux.DiscardCost(1))
  e2:SetOperation(function(e,tp)
    local z=Duel.SelectZone(tp,Duel.GetSigniZones(1-tp))
    if not z then return end
    -- [の間] 존에 건다. 나중에 나온 시그니도, 이 키가 떠난 뒤에도(FAQ 2·3). 다음 내 턴이 시작할 때까지(FAQ)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_POWER)
    e1:SetTargetRange(0,LOCATION_SIGNI)
    e1:SetTarget(function(e,x) return x:IsSigni() and x:GetZone()==z end)
    e1:SetValue(function(e,x) return -2000*x:GetLevel() end)
    e1:SetReset(RESET_MY_TURN)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
