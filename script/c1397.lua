-- WD23-044-EA ＦＩＳＨＩＮＧ
-- このスペルを使用する際、使用コストとして追加で手札を１枚捨ててもよい。
-- 以下の２つから１つを選ぶ。追加で手札を１枚捨てていた場合、代わりに２つを選ぶ。
-- ①あなたのトラッシュから《ライフバースト》を持つカード１枚を対象とし、それを手札に加える。
-- ②あなたのデッキから《ライフバースト》を持つカード１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local picked,modes  -- 선언 때 고른 카드(추가 코스트)와 모드
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local h=e:GetHandler()
    picked=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x~=h end,tp,LOCATION_HAND,0,nil),0,1)
    modes={true,true}
    if picked:GetCount()==0 then
      local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
      modes={m==0,m==1}
    end
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if picked:GetCount()>0 then Duel.SendToTrash(picked,REASON_COST+REASON_DISCARD) end
  end)
  -- 코스트로 놓인 카드도 대상이 된다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if modes[1] then Duel.SelectTarget(tp,Card.IsLifeBurst,tp,LOCATION_TRASH,0,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if modes[1] and tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    if modes[2] then aux.SearchToHand(tp,Card.IsLifeBurst,1) end
  end)
  c:RegisterEffect(e1)
end
