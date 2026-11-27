-- WX09-016 混沌の豊穣　シュブニグラ
-- 《クロスアイコン》 《コードアンチ　ヨグソトス》の右
-- 【常】：あなたのダウン状態のシグニは対戦相手のシグニの効果を受けない。
-- 【クロス自】：このシグニが《ヘブン》したとき、対戦相手のパワー10000以下のすべてのシグニをトラッシュに置く。
-- ライフバースト：あなたのデッキから白か黒のシグニ１枚を探して公開し手札に加えるか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,590,CROSS_RIGHT)
  -- [の間] 【常】 シグニのライフバースト도(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and not x:IsUp() end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_HEAVEN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,1):GetFirst()
    if x then
      Duel.RevealCards(x)
      -- 예 = 장에 낸다, 아니오 = 패에 넣는다
      if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
