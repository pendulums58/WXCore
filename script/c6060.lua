-- WXEX1-26 白羅星　ジ・アース
-- 【出現条件】《メインフェイズアイコン》《アタックフェイズアイコン》合計５枚のレゾナではない＜宇宙＞のシグニをあなたのエナゾーンと場からトラッシュに置く
-- 【常】：対戦相手のセンタールリグの基本リミットは５になる。
-- 【自】：あなたのアタックフェイズ開始時、ターン終了時まで、あなたのすべての＜宇宙＞のシグニは【アサシン】と【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,5,aux.NonResonaClass(RACE_UCHU),LOCATION_ENA+LOCATION_SZONE,TIMING_MAIN+TIMING_ATTACK)
  -- [の間] 【常】 基本リミットは5になる(Lv4 리미트 11 기준 -6으로 근사)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_UPDATE_LIMIT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_LRIG)
  e1:SetValue(-6)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp)
    -- [まで] ターン終了時まで、あなたのすべての＜宇宙＞のシグニは【アサシン】と【ダブルクラッシュ】を得る
    for x in Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_UCHU),tp,LOCATION_SZONE,0,nil):Iter() do
      aux.GrantKeyword(e,x,EFFECT_ASSASSIN)
      aux.GrantKeyword(e,x,EFFECT_DOUBLE_CRUSH)
    end
  end)
  c:RegisterEffect(e2)
end
