-- WXK01-074 コードライド　タクシー
-- 【ドライブ常】：【ダブルクラッシュ】
-- 【自】：このシグニがドライブ状態になったとき、あなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを＋5000する。
-- （【ドライブ常】はそのシグニがドライブ状態であるかぎり有効である）
-- （【ダブルクラッシュ】を持つシグニがアタックによってダメージを与えた場合ライフクロスを１枚ではなく２枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【ドライブ常】 능력을 잃으면 없다(FAQ 5)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsDrive() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 이미 ドライブ状態면 아니다(FAQ 3)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_DRIVE)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,5000)  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e2)
end
