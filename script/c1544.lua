-- WDK06-R01 凛武の記憶　リル
-- 【常】：あなたのターンの間、あなたの＜アーム＞のシグニのパワーを＋3000する。
-- 【出】：あなたのデッキの上からカードを３枚見る。その中から＜アーム＞のシグニ１枚を場に出し、残りを好きな順番でデッキの一番下に置く。その後、この方法で場に出たシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【出】：あなたの場に《メル＝マドラー》がいる場合、【エナチャージ２】をする。
local s,id=GetID()
s.arm=aux.ClassFilter(0,RACE_ARM)  -- ＜アーム＞のシグニ
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  e1:SetTarget(function(e,x) return s.arm(x) end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  -- 내지 못하면 바니시하지 않는다(FAQ 2·3). 리프레시는 처리한 뒤(FAQ 5)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local sc=Duel.SelectCards(tp,g:Filter(s.arm,nil),0,1):GetFirst()
    local put=sc and Duel.PutOnField(sc,tp)
    local rest=g:Filter(function(x) return not (put and x==sc) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
    if not (put and sc:IsLocation(LOCATION_SZONE)) then return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=sc:GetPower() end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsCardName(1023) end,tp,LOCATION_KEY,0,nil):GetCount()>0 then Duel.EnaCharge(tp,2) end
  end)
  c:RegisterEffect(e3)
end
