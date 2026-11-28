-- WXK02-004 カーニバル　†Q†
-- 【自】：このルリグがアタックしたとき、あなたのトラッシュにカードが２５枚以上ある場合、対戦相手は、手札を１枚捨て対象の自分のシグニ１体を場からトラッシュに置き自分のエナゾーンから対象のカード１枚をトラッシュに置く。
-- 【出】：対戦相手のシグニ１体を対象とし、それをバニッシュする。あなたのデッキの上からそのシグニのレベルと同じ枚数のカードをトラッシュに置く。
-- 【起】《ゲーム１回》ジョーカー《コインアイコン》《コインアイコン》：このゲームの間、あなたはキーを２枚まで場に出すことができる。あなたのルリグデッキからキー１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()<25 then return end
    -- 상대가 고른다. 【シャドウ】는 고를 수 없다(FAQ 3)
    local p=1-tp
    aux.Discard(p,1)
    local x=Duel.SelectTarget(p,Card.IsSigni,p,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
    local y=Duel.SelectTarget(p,nil,p,LOCATION_ENA,0,1,1,nil):GetFirst()
    if y then Duel.SendToTrash(y,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    local lv=0
    if tc and tc:IsRelateToEffect(e) then
      lv=tc:GetLevel()
      if Duel.Banish(tc)==0 then lv=0 end
    end
    -- 바니시한 것이 없으면 0장(FAQ 5)
    if lv>0 then
      local g=Duel.GetDecktopGroup(tp,lv)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(2)
  e3:SetOperation(function(e,tp,eg)
    -- 「キーを２枚まで」는 근사: 키 존이 비어 있을 때만 낸다(키 존은 하나)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_KEY) end,tp,LOCATION_LDECK,0,nil)
    if g:GetCount()==0 or Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil):GetCount()>0 then return end
    Duel.PutKey(Duel.SelectCards(tp,g,1,1):GetFirst(),tp)
  end)
  c:RegisterEffect(e3)
end
