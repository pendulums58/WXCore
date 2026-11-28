-- WXEX1-46 深淵との契約　ジルドレイ
-- 【常】：あなたの＜悪魔＞のシグニは【アサシン】を得る。
-- 【出】《黒》：あなたのトラッシュからレベル４以下の＜悪魔＞のシグニを２枚まで対象とし、それらを手札に加える。
-- 【出】《黒》：対戦相手のルリグトラッシュからアーツ１枚を対象とし、それをコストを支払わずに使用する。それがチェックゾーンから別の領域に移動される場合、代わりにゲームから除外される。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{K}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) and x:GetLevel()<=4 end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{K}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_ARTS) end,tp,0,LOCATION_LTRASH,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.UseFree(tc,tp)
      -- チェックゾーンから別の領域に移動される代わりにゲームから除外
      if not tc:IsLocation(LOCATION_EXCLUDED) then Duel.Exclude(tc) end
    end
  end)
  c:RegisterEffect(e3)
end
