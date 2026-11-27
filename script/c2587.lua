-- WX13-006A 黒幻蟲　オウグソク【ＦＡ】
-- 【出現条件】《メインフェイズアイコン》合計３枚のレゾナではない＜凶蟲＞のシグニをあなたの手札と場からトラッシュに置く
-- 【常】：【チャーム】が付いている対戦相手のシグニのパワーを－5000する。
-- 【自】：このシグニが場を離れたとき、あなたのトラッシュから＜凶蟲＞のシグニを２枚まで対象とし、それらを手札に加える。
-- 【出】：ターン終了時まで、【チャーム】が付いている対戦相手のすべてのシグニのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_KYOUCHU),LOCATION_HAND+LOCATION_SZONE)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:GetCharm()~=nil end)
  e1:SetValue(-5000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetOperation(function(e,tp)
    local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,tp,LOCATION_TRASH,0,0,2,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-10000) end  -- [まで]
  end)
  c:RegisterEffect(e3)
end
