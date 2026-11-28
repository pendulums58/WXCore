-- WXEX1-16 アイヤイ★フルハウス
-- 【自】《ターン１回》：あなたのレゾナ１体が場に出たとき、あなたのトラッシュからそのレゾナの出現条件のためにトラッシュに置いたカードを２枚まで対象とし、あなたのターンの場合、それらをエナゾーンに置く。
-- 【起】《アタックフェイズアイコン》《コインアイコン》：あなたのレゾナ１体を対象とし、ターン終了時まで、それは「【常】：バニッシュされない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    return eg:Filter(function(x) return x:GetControler()==tp and x:IsType(TYPE_RESONA) end,nil):GetCount()>0
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local rc=eg:Filter(function(x) return x:GetControler()==tp and x:IsType(TYPE_RESONA) end,nil):GetFirst()
    local mats={}
    if rc then for _,cid in ipairs(rc:GetResonaMaterials()) do mats[cid]=true end end
    Duel.SelectTarget(tp,function(x) return mats[x:GetCode()] end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    if Duel.GetTurnPlayer()~=tp then return end
    local g=Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCoinCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_RESONA) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      -- [まで] 「【常】：バニッシュされない。」を得る
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE)
      g:SetCode(EFFECT_CANNOT_BANISH)
      g:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(g)
    end
  end)
  c:RegisterEffect(e2)
end
