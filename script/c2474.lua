-- WX11-021 多元描写
-- 【チェイン】《緑》《白》
-- 以下の３つから１つを選ぶ。
-- ①対戦相手のセンタールリグ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
-- ②このターンにあなたライフクロスが対戦相手の効果によってクラッシュされていた場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- ③あなたのデッキからレベル２以下のシグニ１枚を探して場に出し、デッキをシャッフルする。そのシグニの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.t0=m&1~=0 and Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if s.t0 and s.t0:IsRelateToEffect(e) then aux.GrantKeyword(e,s.t0,EFFECT_CANNOT_ATTACK) end
    if m&2~=0 and Duel.GetCrushedCount(tp)>0 then local d=Duel.GetDecktopGroup(tp,1) if d:GetCount()>0 then Duel.SendToLife(d) end end
    if m&4~=0 then local x=aux.Search(tp,function(c) return c:IsSigni() and c:GetLevel()<=2 end,1):GetFirst() if x then Duel.PutOnField(x,tp,true) end aux.ShuffleDeck(tp) end
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
    -- 【チェイン】
    do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) end)
      e1:SetEnaCost("{W}")
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
