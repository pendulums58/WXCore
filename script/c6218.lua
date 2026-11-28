-- WXK01-035 セーブ/メイデン　イオナ
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《アタックフェイズアイコン》エクシード３（あなたのルリグの下からカードを合計３枚ルリグトラッシュに置く）：このターン、対戦相手のシグニは可能ならばアタックしなければならない。このターン終了時、このターンにアタックしたすべてのシグニをバニッシュする。
-- 【出】：あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
-- 【起】《ターン１回》《黒》：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(3)
    g:SetTiming(TIMING_ATTACK)
    g:SetOperation(function(e,tp)
      -- [の間] 「このターン」
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_MUST_ATTACK)
      e1:SetTargetRange(0,LOCATION_SZONE)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
      local e2=Effect.CreateEffect(e:GetHandler())
      e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
      e2:SetCode(EVENT_TURN_END)
      e2:SetOperation(function()
        local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasAttacked() end,tp,0,LOCATION_SZONE,nil)
        if g:GetCount()>0 then Duel.Banish(g) end
      end)
      e2:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e2,tp)
    end)
    local e91=Effect.CreateEffect(c)
    e91:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e91:SetDescription(aux.Ability(id,0))
    e91:SetCode(EFFECT_GRANT)
    e91:SetRange(LOCATION_KEY)
    e91:SetTargetRange(LOCATION_LRIG,0)
    e91:SetLabelObject(g)
    c:RegisterEffect(e91)
  end
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_KEY)
  e3:SetCountLimit(1)
  e3:SetEnaCost("{B}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-3000)  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e3)
end
