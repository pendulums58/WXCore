-- WD14-011 弄命の侯爵　アモノウル
-- 【自】：あなたの＜悪魔＞のシグニ１体がバニッシュされたとき、あなたのトラッシュからそのシグニより低いレベルを持つシグニ１枚を対象とし、それを場に出す。
-- 【出】：あなたの他のすべてのシグニをトラッシュに置く。その後、この方法でトラッシュに置いたシグニ１体につき対戦相手のシグニ１体を対象とし、それらをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①手札を２枚捨てる。この方法で手札を２枚捨てた場合、あなたのデッキの一番上のカードをライフクロスに加える。②あなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 자신이 바니시돼도 발동한다(FAQ 1). ev = 바니시된 시그니의 레벨
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsClass(0,RACE_AKUMA) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<ev end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  -- 상대 시그니가 없어도 강제(FAQ 2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local n=Duel.SendToTrash(Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,e:GetHandler()),REASON_EFFECT)
    n=math.min(n,Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):GetCount())  -- 「1체당 1체」라 있는 만큼
    if n==0 then return end
    Duel.Banish(Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil))
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
      -- 1장뿐이면 그 1장을 버리지만 라이프는 더하지 않는다(FAQ 3)
      local n=math.min(2,Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount())
      if n==0 then return end
      if Duel.SendToTrash(Duel.SelectDiscard(tp,n,n),REASON_EFFECT+REASON_DISCARD)==2 then
        Duel.SendToLife(Duel.GetDecktopGroup(tp,1))
      end
      return
    end
    local tc=Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_AKUMA),tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
