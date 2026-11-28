-- SP33-015 ＢＬＵＥ　ＬＲＩＧ（3周年記念カード）
-- ゲームを開始する際に、このルリグを表向きにしたとき、<ピルルク>・<エルドラ>・<ミルルン>・<あや>から1つを選択する。このルリグは選択されたルリグタイプを持つ。<あや>を選択した場合、追加で《コインアイコン》《コインアイコン》《コインアイコン》《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 서로 쓰면 선공부터, 상대 레벨 0을 본 뒤에 고른다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_OPEN)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
    local t={LRIG_PIRULUK,LRIG_ELDORA,LRIG_MILULUN,LRIG_AYA}
    Duel.SetLrigType(e:GetHandler(),t[m+1])
    if m==3 then Duel.AddCoin(tp,4) end
  end)
  c:RegisterEffect(e1)
end
