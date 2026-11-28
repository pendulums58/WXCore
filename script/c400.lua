-- WXK10-002 メンダコギロチン
-- 以下の５つから２つまで選ぶ。
-- ①このターン、対戦相手はスペルを使用できない。
-- ②対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失う。
-- ③対戦相手のトラッシュにあるカードを３枚まで対象とし、それらをゲームから除外する。
-- ④対戦相手のシグニ１体を対象とし、それをトラッシュに置く。手札を２枚捨てる。
-- ⑤あなたのデッキの上からカードを２枚トラッシュに置く。その後、あなたのトラッシュから白か黒のシグニを合計２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))) do
      if m==0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_USE)
        e1:SetTargetRange(0,1)
        e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if not tc then return end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LOSE_ABILITY)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:GrantEffect(e1)
      elseif m==2 then
        local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,0,3,nil)
        if g:GetCount()>0 then Duel.Exclude(g) end
      elseif m==3 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if not tc then return end
        Duel.SendToTrash(tc,REASON_EFFECT)
        aux.Discard(tp,2)
      elseif m==4 then
        local g=Duel.GetDecktopGroup(tp,2)
        if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
        local h=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_TRASH,0,0,2,nil)
        if h:GetCount()>0 then Duel.SendToHand(h) end
      end
    end
  end)
  c:RegisterEffect(e1)
end
