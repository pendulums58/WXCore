-- WX11-059 運命の左糸　アトロポス
-- 《クロスアイコン》《運命の右糸　ラケシス》の左
-- 【クロス常】：このシグニの基本パワーは5000になる。
-- 【クロス出】：あなたのデッキの一番上を公開する。それが＜天使＞のシグニの場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2504,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsCross() end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,1)):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
end
