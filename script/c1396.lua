-- WD23-041-EA 大水罠　ルアー
-- 【出】：あなたのトラッシュから《大水罠　ルアー》以外のそれぞれレベルの異なる青のシグニ４枚をデッキに加えてシャッフルする。そうした場合、あなたのデッキの上からカードを２枚見る。その中から１枚を手札に加え、残りをデッキの一番上に戻す。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 4장을 고를 수 있으면 반드시 돌린다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLUE) and x:GetCode()~=id end,tp,LOCATION_TRASH,0,nil)
    if not s.four(g) then return end
    Duel.SetSelectCheck(function(sg) return sg:GetCount()==4 and aux.DistinctLevels(sg) end)
    Duel.SendToDeckShuffle(Duel.SelectCards(tp,g,4,4),tp)
    local top=Duel.GetDecktopGroup(tp,2)
    if top:GetCount()==0 then return end
    Duel.ConfirmCards(tp,top)
    Duel.SendToHand(Duel.SelectCards(tp,top,1,1))
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
-- 레벨이 다른 4장을 고를 수 있는가
function s.four(g)
  local lv,n,any={},0,0
  for x in g:Iter() do
    if x:HasKeyword(EFFECT_ANY_LEVEL) then
      any=any+1
    elseif not lv[x:GetLevel()] then
      lv[x:GetLevel()]=true
      n=n+1
    end
  end
  return n+any>=4
end
