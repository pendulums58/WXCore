-- WXK09-047 コードアート　Ｗ・Ｓ・Ｂ
-- 【自】：このシグニに《改造素材》が使用されたとき、あなたのエナゾーンにレベル１～４の＜電機＞のシグニがそれぞれ２枚以上ある場合、ターン終了時まで、このシグニは「【常】：バニッシュされない。」と「【常】：コストの合計が１以下の対戦相手のアーツの効果を受けない。」を得る。
-- 【自】：あなたが《改造素材》１枚を使用したとき、あなたのエナゾーンから＜電機＞のシグニを１枚まで対象とし、それを手札に加える。
-- ライフバースト：あなたのトラッシュから＜電機＞のシグニを２枚まで対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「コストの合計が１以下の…」 뒷부분은 아직(バニッシュされない만)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CUSTOM+6974)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) and (function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<2 then return false end end return true end)(tp) then aux.GrantKeyword(e,h,EFFECT_CANNOT_BANISH) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_CUSTOM+6974)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e2:SetOperation(function(e,tp,eg)
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
