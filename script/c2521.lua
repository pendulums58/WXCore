-- WX11-074 羅植　スズビラ
-- 【出】：白、赤、青、黒から２つを選ぶ。あなたのデッキの上からカードを２枚公開する。その中から選んだ色１つにつきその色を持つシグニ１枚を手札に加えるかエナゾーンに置く。残りを好きな順番でデッキの一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local cols={COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_BLACK}
    local pick={}
    for _,i in ipairs(Duel.SelectModes(tp,2,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do pick[#pick+1]=cols[i+1] end
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    for _,col in ipairs(pick) do
      local x=Duel.SelectCards(tp,g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) and c:IsSigni() and c:IsColor(col) end,nil),0,1):GetFirst()
      -- 예 = 패, 아니오 = 에나
      if x then if Duel.SelectYesNo(tp) then Duel.SendToHand(x) else Duel.SendToEna(x) end end
    end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e1)
end
