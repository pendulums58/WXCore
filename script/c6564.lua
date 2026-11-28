-- WXK05-022 コードアクセル　パンツァーガール
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたの他の＜乗機＞のシグニ１体を場からトラッシュに置いてもよい。そうした場合、それをバニッシュする。
-- 【ドライブ自】《ターン１回》：このシグニが対戦相手のライフクロスをクラッシュしたとき、《赤》《赤》《赤》を支払ってもよい。そうした場合、あなたのデッキの上からカードを３枚公開する。その中から赤のシグニ１枚を場に出し、残りをトラッシュに置く。
-- ライフバースト：あなたのトラッシュから＜乗機＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end)(x) and x~=h end,tp,LOCATION_SZONE,0,nil)
    if tc and tc:IsRelateToEffect(e) and g:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)>0 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 【ドライブ自】
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_CRUSHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) local h=e:GetHandler() return ep~=tp and h:IsDrive() and Duel.GetCrusher()==h end)
  e2:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{R}{R}{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}{R}{R}"),REASON_COST)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local x=Duel.SelectCards(tp,g:Filter(function(y) return y:IsSigni() and y:IsColor(COLOR_RED) end,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if not (Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==1 and Duel.PutOnField(tc,tp)) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e9)
end
