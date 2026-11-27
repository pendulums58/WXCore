-- WX11-018 チェイン・Ｂ＆Ｂ
-- 【チェイン】《青》《黒》（このターン、あなたが次にアーツを使用する場合、それの使用コストは《青×1》《黒×1》減る）
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。
-- ②あなたのトラッシュから無色ではないシグニ１枚を対象とし、それを手札に加える。
-- ③対戦相手の手札と、対戦相手のデッキの一番上を見る。
-- ④カードを２枚引き、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.t0=m&1~=0 and Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
    s.t1=m&2~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if s.t0 and s.t0:IsRelateToEffect(e) then aux.AddPower(e,s.t0,-3000) end
    if s.t1 and s.t1:IsRelateToEffect(e) then Duel.SendToHand(s.t1) end
    if m&4~=0 then Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)) local d=Duel.GetDecktopGroup(1-tp,1) if d:GetCount()>0 then Duel.ConfirmCards(tp,d) end end
    if m&8~=0 then Duel.Draw(tp,2) aux.Discard(tp,1) end
    -- 【チェイン】
    do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) end)
      e1:SetEnaCost("{U}")
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
      e1:SetEnaCost("{B}")
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
