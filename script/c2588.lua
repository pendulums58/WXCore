-- WX13-006B 黒幻蟲　オウグソク【ＨＳ】
-- 【出現条件】《スペルカットインアイコン》合計２枚のレゾナではない＜凶蟲＞のシグニをあなたの手札とエナゾーンと場からトラッシュに置く
-- 【出】：対戦相手のチェックゾーンにスペルがある場合、以下の２つから１つを選ぶ。この【出】能力はそのスペルの効果より先に発動する。
-- ①対戦相手のトラッシュにあるスペルを２枚まで対象とし、それらをゲームから除外する。
-- ②あなたのトラッシュからレベル３以下の＜凶蟲＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,aux.NonResonaClass(RACE_KYOUCHU),LOCATION_HAND+LOCATION_ENA+LOCATION_SZONE,TIMING_CUTIN)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e,tp) return Duel.GetCutinSpell()~=nil end)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local g=Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,0,LOCATION_TRASH,0,2,nil)
      if g:GetCount()>0 then Duel.Exclude(g) end
    else
      local g=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_TRASH,0,0,2,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
    end
  end)
  c:RegisterEffect(e1)
end
