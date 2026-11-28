-- WXEX1-60 轟炎　フレイスロ准尉
-- 【自】《ターン１回》：あなたのカード名に《フレイスロ》を含むシグニがアタックしたとき、カード名に《フレイスロ》を含む他のシグニ１体を対象とし、それをアップする。
-- 【出】：あなたのトラッシュからカード名に《フレイスロ》を含むシグニを５枚まで対象とし、それらをデッキに加えてシャッフルする。その後、この方法でデッキに加えた枚数と同じレベルを持つ対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    local a=eg:GetFirst()
    return a and a:GetControler()==tp and a:IsSigni() and aux.NameHas(a,"フレイスロ")
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,eg:GetFirst())
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Up(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,tp,LOCATION_TRASH,0,0,5,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e)
    local n=g:GetCount()
    if n>0 then
      Duel.SendToDeckShuffle(g,tp)
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==n end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e2)
end
