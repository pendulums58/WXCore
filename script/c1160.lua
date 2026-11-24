-- WD07-011 コードメイズ　凱旋
-- 【常】：対戦相手がシグニを配置する場合、可能ならばこのシグニの正面に配置しなければならない。
-- 【起】《ダウン》手札を１枚捨てる：あなたのデッキからレベル２以下の黒のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_MUST_FRONT)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  -- 패가 0장이면 쓸 수 없다(FAQ 2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      return e:GetHandler():IsUp() and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>0
    end
    Duel.Down(e:GetHandler())
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_COST+REASON_DISCARD)
  end)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) and x:IsLevelBetween(0,2) end,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e3)
end
