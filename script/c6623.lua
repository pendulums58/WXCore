-- WXK06-005 コード・ピルルク　ＡＰＥＸ　ＫＥＹ
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード２：あなたのトラッシュにあるスペル１枚を対象とし、それをコストを２倍支払って使用する。このターン、それがチェックゾーンから別の領域に移動される場合、代わりにゲームから除外される。
-- 【自】《ターン１回》：あなたがスペルを使用したとき、対戦相手のシグニ１体を対象とし、《無》を支払ってもよい。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(2)
    g:SetTiming(TIMING_ATTACK)
    g:SetCountLimit(1)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,1,1,nil)
    end)
    g:SetOperation(function(e,tp)
      -- 코스트를 2배 내고 쓴다. 이 턴 체크 존에서 옮겨지면 제외(근사: 쓴 뒤 트래시에 있으면 제외)
      local tc=Duel.GetFirstTarget()
      if not (tc and tc:IsRelateToEffect(e)) then return end
      local cost=tc:GetEnaCost()..tc:GetEnaCost()
      if not Duel.CanPayEna(tp,cost) then return end
      if cost~="" then Duel.SendToTrash(Duel.SelectEnaCost(tp,cost),REASON_COST) end
      Duel.UseFree(tc,tp)
      if tc:IsLocation(LOCATION_TRASH) then Duel.Exclude(tc) end
    end)
    local e91=Effect.CreateEffect(c)
    e91:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e91:SetDescription(aux.Ability(id,0))
    e91:SetCode(EFFECT_GRANT)
    e91:SetRange(LOCATION_KEY)
    e91:SetTargetRange(LOCATION_LRIG,0)
    e91:SetLabelObject(g)
    c:RegisterEffect(e91)
  end
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_USE_CARD)
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_SPELL) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{C}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{C}"),REASON_COST)
    Duel.Banish(tc)
  end)
  c:RegisterEffect(e2)
end
