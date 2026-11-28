-- WXK01-TK-01A 棘々迷路
-- シグニ１体を対象とし、ターン終了時まで、それのパワーを＋2000する。
-- （このカードがルリグデッキとチェックゾーン以外に置かれる場合、代わりにゲームから除外される）
local s,id=GetID()
function s.initial_effect(c)
  -- 루리그 덱·체크 존 밖에 놓이는 경우 대신 게임에서 제외(코어 룰)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,2000)  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e1)
end
