-- WXK07-001 炎真爛漫
-- このアーツはあなたのセンタールリグが＜花代＞の場合か、あなたのセンタールリグがレベル４以上の場合にしか使用できない。
-- あなたのセンタールリグ１体を対象とし、このゲームの間、それは「【自】：あなたのアタックフェイズ開始時、数字１つを宣言する。対戦相手はこのアタックフェイズの間、無色のカードでエナコストを支払えず、宣言された数字と同じレベルのシグニで【ガード】ができず、自身のセンタールリグがレベル４以上の場合一度しかアーツを使用できない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and (lc:IsLrigType(LRIG_HANAYO) or lc:GetLevel()>=4) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_LRIG,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      -- [の間] このゲームの間. 그로우하면 잃는다(FAQ 1)
      -- 근사: 「無色のカードでエナコストを支払えず」는 아직, 「一度しかアーツを使用できない」는 이 턴에 이미 아츠를 썼으면 쓸 수 없다
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
      g:SetDescription(aux.Stringid(id,0))
      g:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
      g:SetRange(LOCATION_LRIG)
      g:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
      g:SetOperation(function(e,tp)
        local n=Duel.AnnounceNumber(tp,0,5)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_GUARD)
        e1:SetTargetRange(0,1)
        e1:SetValue(n)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        local olc=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LRIG,0,nil):GetFirst()
        if olc and olc:GetLevel()>=4 then
          local e2=Effect.CreateEffect(e:GetHandler())
          e2:SetType(EFFECT_TYPE_FIELD)
          e2:SetCode(EFFECT_CANNOT_USE_ARTS)
          e2:SetTargetRange(0,1)
          e2:SetCondition(function() return Duel.GetPhase()==PHASE_ATTACK and Duel.GetArtsUsedCount(1-tp)>=1 end)
          e2:SetReset(RESET_PHASE+PHASE_END)
          Duel.RegisterEffect(e2,tp)
        end
      end)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_GRANT)
      e1:SetLabelObject(g)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
