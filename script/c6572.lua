-- WXK05-030 飛翔する閃光
-- 対戦相手の白、赤、青、緑、黒のシグニをそれぞれ１体対象とし、それらをトラッシュに置く。
-- あなたのデッキから白、赤、青、緑、黒のカードをそれぞれ１枚まで探して公開し手札に加え、デッキをシャッフルする。
-- 【常】：【マルチエナ】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local cols={COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}
    local g=Group.CreateGroup()
    for _,col in ipairs(cols) do
      local x=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:IsColor(col) and not g:IsContains(y) end,tp,0,LOCATION_SZONE,0,1,nil):GetFirst()
      if x then g:AddCard(x) end
    end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local h=Group.CreateGroup()
    for _,col in ipairs(cols) do
      local x=aux.Search(tp,function(y) return y:IsColor(col) and not h:IsContains(y) end,1):GetFirst()
      if x then h:AddCard(x) end
    end
    if h:GetCount()>0 then Duel.RevealCards(h) Duel.SendToHand(h) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 에나 존에서만
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_MULTI_ENA)
  e2:SetRange(LOCATION_ENA)
  c:RegisterEffect(e2)
end
