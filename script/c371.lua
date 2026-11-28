-- PR-K047 ５周年ありがとう！（ウィクロス大感謝祭　来場者特典）
-- ゲームを開始する際に、このルリグを表向きにしたとき、＜タマ＞・＜リル＞・＜ピルルク＞から１つを選択する。このルリグは選択されたルリグタイプを持つ。＜リル＞を選択した場合、追加で《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 서로 쓰면 선공부터, 상대 레벨 0을 본 뒤에 고른다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_OPEN)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    local t={LRIG_TAMA,LRIG_RIL,LRIG_PIRULUK}
    Duel.SetLrigType(e:GetHandler(),t[m+1])
    if m==1 then Duel.AddCoin(tp,1) end
  end)
  c:RegisterEffect(e1)
end
