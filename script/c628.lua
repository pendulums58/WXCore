-- SP38-004 十年一昔（「ウィクロス 10th Anniversary Book」付録）
-- このアーツを使用する際、使用コストとして追加で《無×3》を支払ってもよい。
-- 以下の２つから１つを選ぶ。追加で《無×3》を支払っていた場合、代わりに２つ選ぶ。
-- ①あなたのトラッシュにあるすべてのカードをデッキに加えてシャッフルし、デッキの一番上のカードをライフクロスに加える。
-- ②対戦相手は自分のトラッシュにあるすべてのカードをデッキに加えてシャッフルし、自分のライフクロス１枚をエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    local more=Duel.CanPayEna(tp,base.."{C}{C}{C}") and Duel.SelectYesNo(tp)
    if more then
      Duel.SetUseCost(base.."{C}{C}{C}")
      e:SetLabel(3)
    else
      e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))+1)
    end
  end)
  -- 트래시가 비어도 섞는다(FAQ 1). 라이프는 맨 위(FAQ 2)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      Duel.SendToDeckShuffle(Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil),tp)
      local g=Duel.GetDecktopGroup(tp,1)
      if g:GetCount()>0 then Duel.SendToLife(g) end
    end
    if m&2~=0 then
      Duel.SendToDeckShuffle(Duel.GetMatchingGroup(nil,tp,0,LOCATION_TRASH,nil),1-tp)
      local top=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil):GetFirst()
      if top then Duel.SendToEna(top) end
    end
  end)
  c:RegisterEffect(e1)
end
