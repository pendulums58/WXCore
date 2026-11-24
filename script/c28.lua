-- WD22-021-U 紅蓮の使者　ミリア
-- 【出】：あなたのセンタールリグが黒の場合、あなたのデッキの上からカードを１０枚トラッシュに置く。その後、この方法で１０枚のカードがトラッシュに置かれた場合、あなたのトラッシュから黒のシグニ５枚を対象とし、それらをデッキに加えてシャッフルする。
-- ライフバースト：対戦相手のセンタールリグかシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not (lc and lc:IsColor(COLOR_BLACK)) then return end
    local g=Duel.GetDecktopGroup(tp,10)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT)<10 then return end
    -- 5장을 대상으로 할 수 없으면 1장도 돌리지 않고 섞기만 한다(FAQ 1·4·5)
    Duel.SendToDeckShuffle(Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,5,5,nil),tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG+LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_CANNOT_ATTACK) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
end
