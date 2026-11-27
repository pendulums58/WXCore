-- WX11-024 リフレッシュ・エンド
-- このターン、対戦相手が次にリフレッシュをした場合、その後でこのターンを終了する。（効果やルールによってターンが終了した時点で、チェックゾーンのカードはトラッシュに置かれ、ターンプレイヤーは手札を６枚になるように捨てて、「このターン」「ターン終了時まで」といった効果は終了する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン、次に」 상대가 리프레시하면 그 뒤 턴 종료
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_REFRESH)
    e1:SetCountLimit(1)
    e1:SetCondition(function(e2,tp2,eg,ep) return ep~=tp end)
    e1:SetOperation(function() Duel.EndTurn() end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
