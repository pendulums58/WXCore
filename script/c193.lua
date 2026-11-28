-- PR-317 サクシード・ディストラクト
-- ターン終了時まで、あなたのセンタールリグは
-- 「【起】エクシード４：対戦相手のシグニ１体を対象とし、それをバニッシュする。」
-- 「【起】エクシード４：カードを２枚引く。」
-- 「【起】エクシード４：あなたのデッキの上からカードを２枚エナゾーンに置く。」
-- を得る。このアーツによってあなたのルリグが得た能力は、使用タイミング《メインフェイズアイコン》《アタックフェイズアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,0))
      g:SetRange(LOCATION_LRIG)
      g:SetExceedCost(4)
      g:SetTiming(TIMING_MAIN+TIMING_ATTACK)
      g:SetTarget(function(e2,tp2,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        Duel.SelectTarget(tp2,Card.IsSigni,tp2,0,LOCATION_SZONE,1,1,nil)
      end)
      g:SetOperation(function(e2,tp2)
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e2) then Duel.Banish(tc) end
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
    do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,1))
      g:SetRange(LOCATION_LRIG)
      g:SetExceedCost(4)
      g:SetTiming(TIMING_MAIN+TIMING_ATTACK)
      g:SetOperation(function(e2,tp2)
        Duel.Draw(tp2,2)
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
    do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,2))
      g:SetRange(LOCATION_LRIG)
      g:SetExceedCost(4)
      g:SetTiming(TIMING_MAIN+TIMING_ATTACK)
      g:SetOperation(function(e2,tp2)
        local g=Duel.GetDecktopGroup(tp2,2)
        if g:GetCount()>0 then Duel.SendToEna(g) end
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
  end)
  c:RegisterEffect(e1)
end
