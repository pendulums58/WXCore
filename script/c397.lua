-- PR-K078 炎魔の冥土　アイリ（カードゲーマー Vol.52 付録）
-- 【自】：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、あなたのデッキの上からカードを３枚公開する。その中からレベル２以下のシグニ１枚を手札に加え、残りを好きな順番でデッキの一番下に置く。
-- 【出】：対戦相手はあなたの手札を１枚見ないで選び、あなたはそれを公開する。それが＜悪魔＞かレベル３以上のシグニの場合、ターン終了時まで、このシグニは【ランサー】を得る。
-- ライフバースト：あなたのトラッシュから＜悪魔＞かレベル３のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local h=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:GetLevel()<=2 end,nil),1,1)
    if h:GetCount()>0 then Duel.SendToHand(h) end
    local r=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if r:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,r),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local x=h:GetCount()>0 and Duel.SelectCards(1-tp,h,1,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    local me=e:GetHandler()
    if x:IsSigni() and (x:IsClass(0,RACE_AKUMA) or x:GetLevel()>=3) and me:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,me,EFFECT_LANCER) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA) or x:GetLevel()==3) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
