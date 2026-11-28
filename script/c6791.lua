-- WXK08-002 歌舞熱曲
-- あなたのセンタールリグが＜タウィル＞の場合、このアーツの使用コストは《赤×2》減る。
-- 以下の３つから１つを選ぶ。
-- ①あなたのトラッシュから赤のシグニ１枚を対象とし、ターン終了時まで、それの基本レベルを１にする。それをレベル１のシグニとして場に出す。ターン終了時、それを場から手札に戻す。
-- ②シグニをパワーの合計が10000以下になるように２体まで対象とし、それらをバニッシュする。
-- ③あなたの赤のセンタールリグ１体を対象とし、ターン終了時まで、それは能力を失い「【自】《ターン２回》：このルリグのアタックが【ガード】されたとき、このルリグをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    if m==0 then
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if not tc then return end
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CHANGE_LEVEL)
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
      if Duel.PutOnField(tc,tp) then
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
        e2:SetCode(EVENT_TURN_END)
        e2:SetCountLimit(1)
        e2:SetOperation(function() if tc:IsLocation(LOCATION_SZONE) then Duel.SendToHand(tc) end end)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
      end
    elseif m==1 then
      Duel.SetSelectCheck(function(sg) local n=0 for x in sg:Iter() do n=n+x:GetPower() end return n<=10000 end)
      local g=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,0,2,nil)
      if g:GetCount()>0 then Duel.Banish(g) end
    else
      local tc=Duel.SelectTarget(tp,function(x) return x:IsColor(COLOR_RED) end,tp,LOCATION_LRIG,0,1,1,nil):GetFirst()
      if not tc then return end
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
      g:SetDescription(aux.Stringid(id,3))
      g:SetCode(EVENT_GUARDED)
      g:SetCountLimit(2)
      g:SetOperation(function(e) local h=e:GetHandler() if h:IsLocation(LOCATION_LRIG) then Duel.Up(h) end end)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_GRANT)
      e1:SetLabelObject(g)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_TAWIL) end)() then return Duel.ReduceCost(base,"{R}{R}",1) end return base end)
end
