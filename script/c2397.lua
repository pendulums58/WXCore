-- WX10-020 緑参ノ遊　スプライド
-- 【出現条件】《アタックフェイズアイコン》＜遊具＞のシグニ２枚をあなたのエナゾーンからトラッシュに置く
-- 【常】：このシグニがバニッシュされる場合、ルリグデッキに戻る代わりにルリグトラッシュに置かれる。
-- 【出】《緑×0》：あなたのエナゾーンからカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,LOCATION_ENA,TIMING_ATTACK)
  -- [の間] 【常】
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_SINGLE)
  e9:SetDescription(aux.Ability(id,1))
  e9:SetCode(EFFECT_RESONA_TO_LTRASH)
  e9:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e9)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
end
