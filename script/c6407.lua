-- WXK03-033 大装　ガディヴァ
-- 【自】：このカードがコストか効果によってシグニの下からトラッシュに置かれたとき、手札を１枚捨ててもよい。そうした場合、カードを１枚引く。
-- 【起】《ターン１回》《赤》《赤》：あなたのデッキから《ライズアイコン》を持つシグニ１枚を探して場に出し、デッキをシャッフルする。（【ライズ】の条件を満たさなければ場に出せない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 룰 처리로 트래시에 간 것은 아니다(FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&(REASON_COST+REASON_EFFECT)~=0 and r&REASON_RULE==0 and e:GetHandler():IsPreviousLocation(LOCATION_SZONE) end)
  e1:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{R}{R}")
  e2:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(y) return y:IsSigni() and y:HasRiseIcon() end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
