-- PR-K048 ５ｔｈ　Ａｎｎｉｖ．Ｈｅｒｏｉｎｅｓ（ウィクロスカード大全K-Ⅱ 付録）
-- このキーを場に出すための《無》コストは白か赤か青でしか支払えない。
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《アタックフェイズアイコン》エクシード３：あなたのデッキからシグニを３枚まで探して場に出し、デッキをシャッフルする。
-- 【出】：対戦相手のシグニ１体を対象とし、それを手札に戻す。対戦相手の手札を１枚見ないで選び、捨てさせる。あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- 키를 낼 때의 《無》는 백·적·청으로만(DB에서 {W/R/U})
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_IGNITION)
  g:SetDescription(aux.Ability(id,2))
  g:SetRange(LOCATION_LRIG)
  g:SetTiming(TIMING_ATTACK)
  g:SetExceedCost(3)
  g:SetOperation(function(e,tp)
    for tc in aux.Search(tp,Card.IsSigni,3):Iter() do Duel.PutOnField(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  local e91=Effect.CreateEffect(c)
  e91:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 센터 루리그가 얻는다
  e91:SetDescription(aux.Ability(id,1))
  e91:SetCode(EFFECT_GRANT)
  e91:SetRange(LOCATION_KEY)
  e91:SetTargetRange(LOCATION_LRIG,0)
  e91:SetLabelObject(g)
  c:RegisterEffect(e91)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,3))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
    local g=aux.Search(tp,Card.IsSigni,1)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
