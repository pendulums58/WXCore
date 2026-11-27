-- WX07-009 白羅星　ジュピタ
-- 【出現条件】 《メインフェイズアイコン》レゾナではない白のシグニ２体をあなたの場からトラッシュに置く
-- 【出】：このレゾナの出現条件で同じ名前のシグニ２体をトラッシュに置いていた場合、あなたのデッキの上からカードを２枚エナゾーンに置く。
-- 【出】：ターン終了時まで、対戦相手のすべてのシグニは能力を失う。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) and x:IsColor(COLOR_WHITE) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local m=e:GetHandler():GetResonaMaterials()
    if #m==2 and m[1]==m[2] then Duel.EnaCharge(tp,2) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  -- [まで] 그때 장에 있는 시그니만(FAQ 1·2)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e2)
end
