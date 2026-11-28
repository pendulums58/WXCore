-- WXK08-050 轟書　オウイ
-- 【起】《ターン１回》《黒》：あなたのシグニの下にある＜ウェポン＞のシグニ１枚を対象とし、それを手札に加える。
-- 【常】：このカードの上にある＜ウェポン＞のシグニは「【起】《ターン１回》《黒》《黒》：あなたのシグニの下にある＜ウェポン＞のシグニ１枚を対象とし、それを手札に加える。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】「このカードの上にある＜ウェポン＞は【起】を得る」는 아직
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{B}")
  e1:SetOperation(function(e,tp,eg)
    local g=(function() local g=Group.CreateGroup() for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do for y in x:GetUnderGroup():Iter() do if (function(x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end)(y) then g:AddCard(y) end end end return g end)()
    if g:GetCount()>0 then Duel.SendToHand(Duel.SelectCards(tp,g,1,1)) end
  end)
  c:RegisterEffect(e1)
end
