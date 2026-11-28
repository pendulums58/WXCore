-- PR-166 ｃｏｍｉｃｓ　ＷＩＸＯＳＳ（WIXOSS1周年記念カード）
-- ゲームを開始する際に、このルリグを表向きにしたとき、＜リメンバ＞・＜アルフォウ＞から１つを選択する。このルリグは選択されたルリグタイプを持つ。
local s,id=GetID()
function s.initial_effect(c)
  -- 서로 쓰면 선공부터 고르고, 상대 레벨 0을 본 뒤에 고른다(FAQ 1·2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_OPEN)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    local t={LRIG_REMEMBER,LRIG_ALFOU}
    Duel.SetLrigType(e:GetHandler(),t[m+1])
  end)
  c:RegisterEffect(e1)
end
