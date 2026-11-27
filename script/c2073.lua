-- WX05-001 創世の巫女　マユ
-- 【グロウ】あなたのルリグデッキから＜タマ＞か＜イオナ＞のルリグ１枚を公開し、それをあなたのセンタールリグの下に置く
-- 【出】：あなたのルリグトラッシュからすべてのルリグをこのカードの下に置き、すべての白と黒のアーツをルリグデッキに戻す。
-- 【起】エクシード１：ターン終了時まで、対戦相手のすべてのシグニは能力を失う。
-- 【起】エクシード５：あなたのエナゾーンからすべてのカードをトラッシュに置き、手札をすべて捨てる。あなたはこのターンの次に、追加の１ターンを得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 루리그 덱의 ＜タマ＞나 ＜イオナ＞를 공개해 센터 아래에
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) and (x:IsLrigType(LRIG_TAMA) or x:IsLrigType(LRIG_IONA)) end,tp,LOCATION_LDECK,0,e:GetHandler())
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
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_LRIG) then return end
    Duel.PutUnder(h,Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) end,tp,LOCATION_LTRASH,0,nil))
    local a=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_LTRASH,0,nil)
    if a:GetCount()>0 then Duel.SendToLrigDeck(a) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(1)
  e2:SetOperation(function(e,tp)
    -- [まで] ターン終了時まで. 처리할 때 장에 있는 시그니만
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(5)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToTrash(h,REASON_EFFECT+REASON_DISCARD) end
    Duel.ExtraTurn(tp)
  end)
  c:RegisterEffect(e3)
end
