-- WX19-041 時英の距離　＃デアイ＃
-- 【起】英知＝４《アタックフェイズアイコン》《緑》《緑》：このシグニをあなたのトラッシュから場に出す。
-- 【起】英知＝７《アタックフェイズアイコン》《緑》：このシグニをあなたのトラッシュから場に出す。
-- （これらの能力は、このシグニがトラッシュにある場合にしか使用できずあなたの場にある＜英知＞のシグニのレベルのみを合計する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_TRASH)
  e1:SetEnaCost("{G}{G}")
  e1:SetTiming(TIMING_ATTACK)
  e1:SetCondition(aux.EichiCon(4))
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRASH)
  e2:SetEnaCost("{G}")
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCondition(aux.EichiCon(7))
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e2)
end
