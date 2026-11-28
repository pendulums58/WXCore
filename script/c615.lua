-- SP33-029 ＢＬＡＣＫ　ＬＲＩＧ（3周年記念カード）
-- ゲームを開始する際に、このルリグを表向きにしたとき、<ウリス>・<ウムル>・<ミュウ>・<アルフォウ>・<ハナレ>・<ナナシ>・<グズ子>から1つを選択する。このルリグは選択されたルリグタイプを持つ。<ナナシ>を選択した場合、追加で《コインアイコン》《コインアイコン》を得て、<グズ子>を選択した場合、追加で《コインアイコン》《コインアイコン》《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 서로 쓰면 선공부터, 상대 레벨 0을 본 뒤에 고른다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_OPEN)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4),aux.Stringid(id,5),aux.Stringid(id,6))
    local t={LRIG_URITH,LRIG_UMR,LRIG_MYU,LRIG_ALFOU,LRIG_HANARE,LRIG_NANASHI,LRIG_GUZUKO}
    Duel.SetLrigType(e:GetHandler(),t[m+1])
    if m==5 then Duel.AddCoin(tp,2) end
    if m==6 then Duel.AddCoin(tp,3) end
  end)
  c:RegisterEffect(e1)
end
