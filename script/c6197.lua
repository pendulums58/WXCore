-- WXK01-003 四型金娘　翠子
-- 【常】：あなたの中央のシグニゾーンにある＜怪異＞のシグニのパワーを＋2000する。
-- 【出】《緑》：あなたのルリグトラッシュから緑のアーツ１枚を対象とし、それをルリグデッキに加える。
-- 【起】《ゲーム１回》テンタクル《コインアイコン》：次の対戦相手のアタックフェイズ開始時、対戦相手のセンタールリグ１体とシグニ１体を対象とし、ターン終了時まで、それらは「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_KAII) end)(x) and x:IsInZone("signi_center") end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{G}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_ARTS) and x:IsColor(COLOR_GREEN) end,tp,LOCATION_LTRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToLrigDeck(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp,eg)
    -- 대상은 상대 어택 페이즈 개시 시에 고른다(FAQ 3)
    local lc=e:GetHandler()
    local e1=Effect.CreateEffect(lc)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
    e1:SetCountLimit(1)
    e1:SetCondition(function() return Duel.GetTurnPlayer()~=tp end)
    e1:SetOperation(function(e2)
      local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil)
      local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if x then g:AddCard(x) end
      for y in g:Iter() do
        -- [まで] ターン終了時まで
        local e3=Effect.CreateEffect(lc)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_CANNOT_ATTACK)
        e3:SetReset(RESET_PHASE+PHASE_END)
        y:GrantEffect(e3)
      end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
