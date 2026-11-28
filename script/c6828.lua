-- WXK08-042 炎魔の蛇梟　アモン
-- 【自】《ビートアイコン》［７枚以上］：あなたのアタックフェイズ開始時、あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
-- 【自】《ビートアイコン》［レベル１、２が各１枚以上］：このシグニがアタックしたとき、【エナチャージ１】をする。（この能力はあなたの【ビート】の中にレベル１とレベル２のシグニが各１枚以上含まれるかぎり有効になる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and aux.BeatCon(function(g) return g:GetCount()>=7 end)(e) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCondition(aux.BeatCon(function(g) local a,b=false,false for x in g:Iter() do if x:IsSigni() and x:GetLevel()==1 then a=true end if x:IsSigni() and x:GetLevel()==2 then b=true end end return a and b end))
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
