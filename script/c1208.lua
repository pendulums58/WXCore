-- WD11-008 黒幻蟲　ヤスデス
-- 【出現条件】《メインフェイズアイコン》以下の３つから２つを選ぶ
-- ①＜凶蟲＞のシグニ１枚をあなたの手札から捨てる
-- ②＜凶蟲＞のシグニ２枚をあなたのエナゾーンからトラッシュに置く
-- ③レゾナではない＜凶蟲＞のシグニ１体をあなたの場からトラッシュに置く
-- 【出】：対戦相手のレベル２以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,s.mat,LOCATION_HAND+LOCATION_ENA+LOCATION_SZONE,TIMING_MAIN,2,s.matcheck)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.filter(tc) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
function s.filter(c) return c:IsSigni() and c:GetLevel()<=2 end
function s.mat(x)
  return x:IsSigni() and x:IsClass(0,RACE_KYOUCHU) and not (x:IsLocation(LOCATION_SZONE) and x:IsType(TYPE_RESONA))
end
-- 같은 것을 두 번 고를 수는 없다(FAQ 1): 패 1·에나 2·장 1 중 두 가지
function s.matcheck(g)
  local hand,ena,field=0,0,0
  for x in g:Iter() do
    if x:IsLocation(LOCATION_HAND) then hand=hand+1
    elseif x:IsLocation(LOCATION_ENA) then ena=ena+1
    else field=field+1 end
  end
  return (hand==1 and ena==2 and field==0) or (hand==1 and ena==0 and field==1) or (hand==0 and ena==2 and field==1)
end
