-- WD23-015-EA エルドラ＆あーや
-- ゲームを開始する際に、このルリグを表向きにしたとき、＜エルドラ＞・＜あや＞から１つを選択する。このルリグは選択されたルリグタイプを持つ。＜あや＞を選択した場合、追加で《コインアイコン》《コインアイコン》《コインアイコン》《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_OPEN)
  e1:SetOperation(function(e,tp)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
      Duel.SetLrigType(e:GetHandler(),LRIG_ELDORA)
    else
      Duel.SetLrigType(e:GetHandler(),LRIG_AYA)
      Duel.AddCoin(tp,4)
    end
  end)
  c:RegisterEffect(e1)
end
