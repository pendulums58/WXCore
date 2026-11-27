-- WX13-005B 白羅星　ニュームーン
-- 【出現条件】《スペルカットインアイコン》合計２枚のレゾナではない＜宇宙＞のシグニをあなたの手札とエナゾーンと場からトラッシュに置く
-- 【出】：対戦相手のチェックゾーンにスペルがある場合、以下の２つから１つを選ぶ。この【出】能力はそのスペルの効果より先に発動する。
-- ①対戦相手のトラッシュにあるシグニを２枚まで対象とし、それらをゲームから除外する。
-- ②このターン、対戦相手はスペルとアーツを使用できない。（カットインされたスペルはこの効果の影響を受けない）
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,aux.NonResonaClass(RACE_UCHU),LOCATION_HAND+LOCATION_ENA+LOCATION_SZONE,TIMING_CUTIN)
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
      local g=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_TRASH,0,2,nil)
      if g:GetCount()>0 then Duel.Exclude(g) end
      return
    end
    -- [の間] 「このターン」 컷인된 스펠은 영향 없다(괄호)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_USE)
    e1:SetTargetRange(0,1)
    e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) or x:IsType(TYPE_ARTS) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
