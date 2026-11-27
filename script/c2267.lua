-- WX08-021 黒幻蟲　サソリス
-- 【出現条件】 《メインフェイズアイコン》＜凶蟲＞のシグニ２枚をあなたの手札から捨てる
-- 【出】：対戦相手のシグニゾーン１つを指定する。このターンと次のターンの間、指定されたシグニゾーンにあるシグニのパワーを－7000する。（このシグニが場を離れてもこの効果は継続する）
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,aux.NonResonaClass(RACE_KYOUCHU),LOCATION_HAND)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  -- 이 시그니가 떠나도 계속(괄호)
  e1:SetOperation(function(e,tp)
    local z=Duel.SelectZone(tp,Duel.GetSigniZones(1-tp))
    if not z then return end
    -- [の間] 이 턴과 다음 턴, 그 존의 시그니
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_POWER)
    e1:SetTargetRange(0,LOCATION_SIGNI)
    e1:SetTarget(function(e,x) return x:GetZone()==z end)
    e1:SetValue(-7000)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
