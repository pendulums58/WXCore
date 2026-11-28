-- WXK06-028 コードラビリンス　アトラン
-- 【自】：このシグニがアタックしたとき、対戦相手のトラッシュからカードを２枚まで対象とし、それらをデッキの一番上に置く。（置く順番は対戦相手が選ぶ）
-- 【起】《ターン１回》《青×0》：プレイヤーを２人まで選ぶ。選ばれた各プレイヤーは手札をすべてデッキに加えてシャッフルし、この方法で自分のデッキに加えたカードの枚数と同じ枚数のカードを引く。この効果によって各プレイヤーは最大５枚までしかカードを引くことができない。
-- ライフバースト：カードを１枚引く。対戦相手は手札を１枚デッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 두는 순서는 상대가(카드 주석)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,0,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then aux.ToDeckTopInOrder(1-tp,g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp,eg)
    for _,p in ipairs({tp,1-tp}) do
      if Duel.SelectYesNo(tp) then
        local h=Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil)
        local n=h:GetCount()
        Duel.SendToDeckShuffle(h,p)
        if n>0 then Duel.Draw(p,math.min(5,n)) end
      end
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    local h=Duel.GetMatchingGroup(nil,1-tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToDeckPosition(Duel.SelectCards(1-tp,h,1,1),1) end
  end)
  c:RegisterEffect(e9)
end
