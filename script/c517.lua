-- WD17-011 金山の西蔵　サンゾウ
-- 【自】：このシグニがライズされたとき、ターン終了時まで、そのシグニのパワーを＋3000する。
-- 【出】《赤》：あなたのデッキから《ライズアイコン》を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_RISEN)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetRiser()
    if tc and tc:IsLocation(LOCATION_SZONE) then aux.AddPower(e,tc,3000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{R}")
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:HasRiseIcon() end,1)
  end)
  c:RegisterEffect(e2)
end
