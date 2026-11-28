-- WXK03-005 フラクタル・ケージ
-- 対戦相手のターンの間、このアーツの使用コストは《無×5》になる。
-- ターン終了時まで、対戦相手のシグニゾーン１つを消す。あなたのトラッシュから対象の＜精元＞のシグニ１枚を手札に加える。
-- 【自】：このカードがエクシードのコストとしてルリグトラッシュに置かれたとき、あなたのトラッシュから＜精元＞のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(SYS_SEIGEN,0),tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local zs=Duel.GetSigniZones(1-tp)
    if #zs>0 then
      local z=Duel.SelectZone(tp,zs)
      if z then
        Duel.RemoveZone(z)
        -- [の間] 「ターン終了時まで」
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
        e1:SetCode(EVENT_TURN_END)
        e1:SetOperation(function() Duel.RestoreZone(z) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
      end
    end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if Duel.GetTurnPlayer()~=tp then return "{C}{C}{C}{C}{C}" end return base end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_LTRASH)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_EXCEED~=0 end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(SYS_SEIGEN,0),tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.PutOnField(tc,tp)
    end
  end)
  c:RegisterEffect(e2)
end
