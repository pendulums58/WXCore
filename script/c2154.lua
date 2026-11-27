-- WX06-036 コードアンチ　ゴルスペ
-- 【出】ルリグデッキから黒のアーツ１枚をルリグトラッシュに置く：あなたのトラッシュから＜古代兵器＞のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) and x:IsColor(COLOR_BLACK) end,tp,LOCATION_LDECK,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,g,1,1))
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
