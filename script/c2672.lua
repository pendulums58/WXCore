-- WX14-006B 緑弐ノ遊　アスレ【ＮＯＲＭＡＬ】
-- 【出現条件】 《スペルカットインアイコン》合計２枚のレゾナではない＜遊具＞のシグニをあなたの手札とエナゾーンと場からトラッシュに置く
-- 【出】：対戦相手のチェックゾーンにスペルがある場合、以下の２つから１つを選ぶ。この【出】能力はそのスペルの効果より先に発動する。
-- ①あなたのデッキの上からカードを３枚エナゾーンに置く。
-- ②対戦相手のトラッシュにあるシグニとスペルをそれぞれ１枚まで対象とし、それらをゲームから除外する。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,aux.NonResonaClass(RACE_YUGU),LOCATION_HAND+LOCATION_ENA+LOCATION_SZONE,TIMING_CUTIN)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e,tp) return Duel.GetCutinSpell()~=nil end)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.EnaCharge(tp,3) return end
    local a=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_TRASH,0,1,nil)
    a:Merge(Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,0,LOCATION_TRASH,0,1,nil))
    if a:GetCount()>0 then Duel.Exclude(a) end
  end)
  c:RegisterEffect(e1)
end
