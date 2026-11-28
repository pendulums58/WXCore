-- PR-470A 現実からの逃避　タマ（コロコロアニキ2019年夏号 付録）
-- 【出現条件】《メインフェイズアイコン》パワーの合計が10000以上になるようにあなたのエナゾーンからシグニを好きな数トラッシュに置く
-- 【自】：あなたのデッキがシャッフルされたとき、ターン終了時まで、このシグニのパワーを＋5000する。
-- 【自】：あなたのアタックフェイズ開始時、このシグニのパワーが10000以上の場合、カードを１枚引く。25000以上の場合、このシグニをルリグデッキに戻し、あなたのルリグデッキから《進化する筋肉　紗倉ひびき》を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,20,Card.IsSigni,LOCATION_ENA,TIMING_MAIN,1,function(g)
    local p=0
    for x in g:Iter() do p=p+x:GetPower() end
    return p>=10000
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_SHUFFLE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  -- 셔플마다(리프레시 포함. FAQ 1·2)
  e1:SetOperation(function(e,tp)
    aux.AddPower(e,e:GetHandler(),5000)  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  -- 레벨이 맞지 않으면 ひびき를 낼 수 없다(FAQ 6)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local p=h:GetPower()
    if p>=10000 then Duel.Draw(tp,1) end
    if p<25000 or not h:IsLocation(LOCATION_SZONE) then return end
    Duel.SendToLrigDeck(h)
    local x=Duel.GetMatchingGroup(function(c) return c:IsCardName(298) end,tp,LOCATION_LDECK,0,nil):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e2)
end
