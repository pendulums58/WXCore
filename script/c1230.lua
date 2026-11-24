-- WD13-001 真名の巫女　マユ
-- 【グロウ】あなたのルリグデッキから＜タマ＞か＜イオナ＞のルリグ１枚を公開し、それをあなたのセンタールリグの下に置く
-- 【出】：あなたのルリグトラッシュからすべてのルリグをこのカードの下に置き、対象のアーツを２枚までルリグデッキに加える。
-- 【起】エクシード２：対戦相手のすべてのシグニをトラッシュに置く。対戦相手はデッキの上からカードを２枚公開する。対戦相手はその中からシグニを２枚まで場に出し、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.lrig,tp,LOCATION_LDECK,0,e:GetHandler())
    if chk==0 then return g:GetCount()>0 end
    local sg=Duel.SelectCards(tp,g,1,1)
    Duel.RevealCards(sg)
    Duel.PutUnder(Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst(),sg)
  end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_ARTS) end,tp,LOCATION_LTRASH,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_LRIG) then
      Duel.PutUnder(h,Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) end,tp,LOCATION_LTRASH,0,nil))
    end
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.SendToLrigDeck(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(2)
  e2:SetOperation(function(e,tp)
    local op=1-tp
    Duel.SendToTrash(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil),REASON_EFFECT)
    local g=Duel.GetDecktopGroup(op,2)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    for tc in Duel.SelectCards(op,g:Filter(Card.IsSigni,nil),0,2):Iter() do Duel.PutOnField(tc,op) end
    Duel.SendToTrash(g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil),REASON_EFFECT)
  end)
  c:RegisterEffect(e2)
end
function s.lrig(c) return c:IsType(TYPE_LRIG) and (c:IsLrigType(LRIG_TAMA) or c:IsLrigType(LRIG_IONA)) end
