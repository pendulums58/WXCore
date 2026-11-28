-- WXK08-001 ドリーム・トライアングル
-- あなたのセンタールリグが＜にじさんじ＞の場合、このアーツの使用コストは《白×2》減る。
-- 以下の３つから２つまで選ぶ。
-- ①対戦相手のシグニを２体まで対象とし、《白》を支払ってもよい。そうした場合、ターン終了時まで、それらは能力を失う。
-- ②シグニ１体を対象とし、《赤》を支払ってもよい。そうした場合、それをバニッシュする。
-- ③シグニ１体を対象とし、《青》を支払ってもよい。そうした場合、それをダウンし、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
      if m==0 then
        local g=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
        if g:GetCount()>0 and Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp) then
          Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
          for x in g:Iter() do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LOSE_ABILITY)
            e1:SetReset(RESET_PHASE+PHASE_END)
            x:GrantEffect(e1)
          end
        end
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc and Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp) then Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST) Duel.Banish(tc) end
      else
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc and Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp) then Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST) Duel.Down(tc) Duel.Draw(tp,1) end
      end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_NIJISANJI) end)() then return Duel.ReduceCost(base,"{W}{W}",1) end return base end)
end
