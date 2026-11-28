-- SPK01-09 大罠　ハート・クイーン（パーティーパックVol.3）
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを５枚公開する。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法で公開されたレベルが奇数のシグニ１枚につき－2000する。公開したカードをシャッフルしてデッキの一番下に置く。
-- 【出】《黒》《黒》：あなたのトラッシュから《大罠　ハート・クイーン》以外のレベルが奇数の＜トリック＞のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：あなたのトラッシュから、対象のレベル１の＜トリック＞のシグニ１枚を場に出し対象のレベル３の＜トリック＞のシグニ１枚を手札に加える。
local s,id=GetID()
function s.trick(x) return x:IsSigni() and x:IsClass(0,RACE_TRICK) end
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  -- 4장 이하면 전부(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local n=g:Filter(function(x) return x:IsSigni() and x:GetLevel()%2==1 end,nil):GetCount()
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and n>0 then aux.AddPower(e,tc,-2000*n) end  -- [まで] ターン終了時まで
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}{B}")
  -- 코스트로 버린 것도 고를 수 있다(FAQ 2)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return s.trick(x) and x:GetLevel()%2==1 and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  -- 한쪽만 있어도 된다(FAQ 3·4)
  e3:SetOperation(function(e,tp)
    local a=Duel.SelectTarget(tp,function(x) return s.trick(x) and x:GetLevel()==1 end,tp,LOCATION_TRASH,0,0,1,nil):GetFirst()
    local b=Duel.SelectTarget(tp,function(x) return s.trick(x) and x:GetLevel()==3 end,tp,LOCATION_TRASH,0,0,1,nil):GetFirst()
    if a then Duel.PutOnField(a,tp) end
    if b and b:IsLocation(LOCATION_TRASH) then Duel.SendToHand(b) end
  end)
  c:RegisterEffect(e3)
end
