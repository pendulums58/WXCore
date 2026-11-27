-- WX20-077 ドライ＝アコニチン
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、対戦相手のすべてのシグニのパワーを－1000する。あなたの場にカード名に《リカブト》を含むシグニがある場合、代わりに－3000する。
-- 【出】：あなたのトラッシュにカード名に《リカブト》を含むカードがある場合、あなたのデッキから《バイオレンス・スプラッシュ》１枚を探す。その後、デッキをシャッフルし、それをコストを支払わずに使用するかトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local v=(Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"リカブト") end,tp,LOCATION_SZONE,0,nil):GetCount()>0) and -3000 or -1000
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,v) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    if not (Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"リカブト") end,tp,LOCATION_TRASH,0,nil):GetCount()>0) then return end
    local x=aux.Search(tp,function(c) return c:IsCardName(2017) end,1):GetFirst()
    aux.ShuffleDeck(tp)
    if not x then return end
    -- 예 = 코스트 없이 사용, 아니오 = 트래시
    if Duel.SelectYesNo(tp) then Duel.UseFree(x,tp) else Duel.SendToTrash(x,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
