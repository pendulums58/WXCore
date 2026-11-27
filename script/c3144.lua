-- WX20-056 戦乱の一輪　オイチ
-- 【自】：このシグニがライズされたとき、ターン終了時まで、そのシグニのパワーを＋3000する。
-- 【自】：このシグニがカード名に《オダノブ》を含むシグニにライズされたとき、ターン終了時まで、そのシグニは「【常】：対戦相手の効果によって、手札に戻らずダウンせず新たに能力を得られない。」を得る。
-- 【出】《赤》：あなたのデッキからカード名に《オダノブ》を含むシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_RISEN)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetRiser()
    if tc and tc:IsLocation(LOCATION_SZONE) then aux.AddPower(e,tc,3000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_RISEN)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetRiser()
    if not (tc and tc:IsLocation(LOCATION_SZONE) and aux.NameHas(tc,"オダノブ")) then return end
    -- [まで] 「手札に戻らず·ダウンせず」(「新たに能力を得られない」는 아직)
    for _,code in ipairs({EFFECT_NO_BOUNCE,EFFECT_NO_DOWN_BY_OPP}) do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(code)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{R}")
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and aux.NameHas(x,"オダノブ") end,1)
  end)
  c:RegisterEffect(e3)
end
