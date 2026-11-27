-- WX17-077 コードイート　サルサス
-- 【起】《緑×0》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニは「【自】：対戦相手のターン終了時、このシグニを場からトラッシュに置いてもよい。そうした場合、あなたのデッキの上からカードを３枚エナゾーンに置くかカードを３枚引く。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddAcce(c,aux.Ability(id,0))
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_TURN_END)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  g:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
    -- 예 = 3장 에나, 아니오 = 3장 뽑는다
    if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,3) else Duel.Draw(tp,3) end
  end)
  -- [の間] 【常】 이것이 붙은 ＜調理＞ 시그니가 얻는다
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_FIELD)
  e9:SetCode(EFFECT_GRANT)
  e9:SetRange(LOCATION_ACCE)
  e9:SetTargetRange(LOCATION_SZONE,0)
  e9:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) end)
  e9:SetLabelObject(g)
  c:RegisterEffect(e9)
end
