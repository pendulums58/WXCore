-- SP27-014 中水罠　オトヒメ（セレクターズパック vol.19）
-- 【常】：あなたの他の青のシグニのパワーを＋2000する。
-- 【自】：このシグニが対戦相手の効果によっていずれかの領域からトラッシュに置かれたとき、以下の３つから１つを選ぶ。
-- ①カードを１枚引く。
-- ②あなたのデッキの一番上のカードをエナゾーンに置く。
-- ③対戦相手のシグニ１体を対象とし、手札を１枚捨ててもよい。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x~=e:GetHandler() and x:IsSigni() and x:IsColor(COLOR_BLUE) end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  -- 어느 영역에서든(FAQ 1). 배틀로 바니시된 것이 트래시로 바뀐 것은 아니다(FAQ 3)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp~=tp and r&REASON_EFFECT~=0 end)
  e2:SetOperation(function(e,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    if m==0 then Duel.Draw(tp,1)
    elseif m==1 then Duel.EnaCharge(tp,1)
    else
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      if tc and h:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)>0 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e2)
end
