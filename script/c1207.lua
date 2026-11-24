-- WD11-007 黒幻蟲　ムカデス
-- 【出現条件】《メインフェイズアイコン》レゾナではない＜凶蟲＞のシグニ２体をあなたの場からトラッシュに置く
-- 【出】：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを、このレゾナの出現条件でトラッシュに置いたシグニのレベルを合計した数だけ－2000する。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,aux.NonResonaClass(RACE_KYOUCHU))
  -- ev = 출현 조건으로 트래시한 시그니의 레벨 합계(출현 조건 없이 나오면 0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(s.opptg)
  e1:SetOperation(function(e,tp,eg,ep,ev)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and ev>0 then aux.AddPower(e,tc,-2000*ev) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
