-- WX19-061 幻水　スズキ
-- 【出】：あなたのデッキの一番上を公開する。それが青のカードの場合、対戦相手のデッキの一番上を見る。＜水獣＞のシグニの場合、カードを１枚引く。スペルの場合、対戦相手のデッキの一番上と対戦相手のライフクロス１枚を入れ替えてもよい。
-- （例えば公開したカードが青の＜水獣＞の場合、対戦相手のデッキの一番上を見てカードを１枚引く）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    if x:IsColor(COLOR_BLUE) then local o=Duel.GetDecktopGroup(1-tp,1) if o:GetCount()>0 then Duel.ConfirmCards(tp,o) end end
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end)(x) then Duel.Draw(tp,1) end
    if x:IsType(TYPE_SPELL) and Duel.SelectYesNo(tp) then
      -- 상대 덱 맨 위와 라이프 클로스 1장을 맞바꾼다
      local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
      local life=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil),1,1):GetFirst()
      if top and life then Duel.SendToDeckPosition(life,1) Duel.SendToLife(top) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
