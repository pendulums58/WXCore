-- WX16-031 コードオーダー　ウェディング
-- 【常】：このシグニには２枚まで【アクセ】を付けることができる。
-- 【常】：あなたのアクセされているシグニのパワーを＋2000する。
-- 【自】：あなたのアタックフェイズ開始時、このシグニのパワーが15000以上の場合、カードを２枚引くかあなたのデッキの上からカードを２枚エナゾーンに置く。
-- ライフバースト：あなたのトラッシュから＜調理＞のシグニ１枚と《アクセアイコン》を持つシグニ１枚をそれぞれ１枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「２枚まで【アクセ】」는 아직(근사 없음)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsAcce() end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and e:GetHandler():GetPower()>=15000 end)
  e2:SetOperation(function(e,tp)
    -- 예 = 2장 뽑는다, 아니오 = 2장 에나
    if Duel.SelectYesNo(tp) then Duel.Draw(tp,2) else Duel.EnaCharge(tp,2) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end,tp,LOCATION_TRASH,0,0,1,nil):GetFirst()
    Duel.SelectTarget(tp,Card.HasAcceIcon,tp,LOCATION_TRASH,0,0,1,a)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
