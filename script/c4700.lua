-- WXDi-D01-004 紡ぎし扉　アト＝トレ
-- 【チーム】＜アンシエント・サプライズ＞
-- 【チーム起】《ターン１回》《緑×0》：それぞれ異なるクラスを持つあなたのシグニ３体を対象とし、ターン終了時まで、それらのパワーを＋３０００する。
-- 【出】：【エナチャージ２】をする。この方法でエナゾーンに置かれたカードが共通するクラスを持たない場合、追加で【エナチャージ１】をする。
local s,id=GetID()
s.team="アンシエント・サプライズ"
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp) return Duel.IsTeam(tp,s.team) end)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(s.enaop)
  c:RegisterEffect(e2)
end
-- 「３体まで」가 아니라 「３体」: 맞는 3체를 못 고르면 쓸 수 없다(FAQ 2)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
  if chk==0 then return g:GetCount()>=3 and aux.DistinctClasses(g) end
  Duel.SetSelectCheck(aux.DistinctClasses)
  Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,3,3,nil)
end
function s.op(e,tp)
  for tc in Duel.GetTargets():Iter() do
    if tc:IsRelateToEffect(e) then
      -- [まで] ターン終了時まで
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_POWER)
      e1:SetValue(3000)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end
end
function s.enaop(e,tp)
  local g=Duel.EnaCharge(tp,2)
  -- 스펠은 클래스가 없어 공통 클래스가 없는 것으로 본다(FAQ 3)
  if g:GetCount()>0 and aux.NoCommonClass(g) then Duel.EnaCharge(tp,1) end
end
