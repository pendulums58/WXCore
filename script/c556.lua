-- SP27-011 羅星　マルカブ（セレクターズパック vol.18）
-- 【出】：あなたの場にレゾナがある場合、以下の４つから１つを選ぶ。
-- ①カードを１枚引く。
-- ②あなたのデッキの一番上のカードをエナゾーンに置く。
-- ③対戦相手のレベル３以下のシグニ１体を対象とし、それを手札に戻す。
-- ④各プレイヤーは自分のデッキの上からカードを４枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 레조나가 있는지는 발동할 때 본다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsType(TYPE_RESONA) end,tp,LOCATION_SZONE,0,nil):GetCount()==0 then return end
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
    if m==0 then Duel.Draw(tp,1)
    elseif m==1 then Duel.EnaCharge(tp,1)
    elseif m==2 then
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.SendToHand(tc) end
    else
      for _,p in ipairs({tp,1-tp}) do
        local g=Duel.GetDecktopGroup(p,4)
        if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
      end
    end
  end)
  c:RegisterEffect(e1)
end
