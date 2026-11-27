-- WX21-034 幻竜　タルボ
-- 【自】：あなたのアタックフェイズ開始時、レゾナではないあなたの＜龍獣＞のシグニ１体を対象とし、《赤》か《緑》を支払ってもよい。そうした場合、ターン終了時まで、このシグニはレベル２であることを除き、それと同じカードになる。（カード名、色、限定条件、クラス、テキスト、パワー、アイコンが変化する）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- 【自】 「それと同じカードになる」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_LIFEBURST)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
end
