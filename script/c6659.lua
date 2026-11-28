-- WXK06-044 コードメイズ　マリタイ
-- 【出】：手札が１枚以上ある各プレイヤーは、手札を１枚デッキの一番下に置きカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    for _,p in ipairs({tp,1-tp}) do
      local h=Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then
        Duel.SendToDeckBottom(Duel.SelectCards(p,h,1,1),false)
        Duel.Draw(p,1)
      end
    end
  end)
  c:RegisterEffect(e1)
end
