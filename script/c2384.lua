-- WX10-005 龍滅連鎖
-- 【チェイン】《赤》《緑》（このターン、あなたが次にアーツを使用する場合、それの使用コストは《赤×1》《緑×1》減る）
-- 以下の３つから２つまで選ぶ。
-- ①対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
-- ②対戦相手は自分のエナゾーンのカードが４枚になるように、エナゾーンからカードをトラッシュに置く。
-- ③あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    if m&1~=0 then s.t0=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if s.t0 and s.t0:IsRelateToEffect(e) then Duel.Banish(s.t0) end
    if m&2~=0 then
      local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ENA,0,nil)
      local n=g:GetCount()-4
      if n>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,g,n,n),REASON_EFFECT) end
    end
    if m&4~=0 then local d=Duel.GetDecktopGroup(tp,1) if d:GetCount()>0 then Duel.SendToLife(d) end end
    -- 【チェイン】
    do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) end)
      e1:SetEnaCost("{R}")
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
    -- 【チェイン】
    do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) end)
      e1:SetEnaCost("{G}")
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
