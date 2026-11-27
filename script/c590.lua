-- WX09-020 コードアンチ　ヨグソトス
-- 《クロスアイコン》《混沌の豊穣　シュプニグラ》の左
-- 【自】：あなたのトラッシュから効果によってカード１枚がデッキに移動したとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－2000する。
-- 【クロス自】：このシグニが《ヘブン》したとき、ターン終了時まで、対戦相手のすべてのシグニのパワーを－10000する。
-- ライフバースト：あなたのトラッシュから白か黒のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,247,CROSS_LEFT)
  -- 1장마다(FAQ 1). 리프레시는 효과가 아니다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_MOVED_TO_DECK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return eg:Filter(function(x) return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_TRASH) end,nil):GetCount()>0 end)
  e1:SetOperation(function(e,tp,eg)
    local n=eg:Filter(function(x) return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_TRASH) end,nil):GetCount()
    for _=1,n do
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if not tc then break end
      aux.AddPower(e,tc,-2000)  -- [まで]
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_HEAVEN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-10000) end  -- [まで]
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local x=Duel.GetFirstTarget()
    if not (x and x:IsRelateToEffect(e)) then x=nil end
    if x then
      Duel.RevealCards(x)
      -- 예 = 장에 낸다, 아니오 = 패에 넣는다
      if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
    end
  end)
  c:RegisterEffect(e3)
end
