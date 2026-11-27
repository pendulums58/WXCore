-- WX09-013 緑幻獣　モモ
-- 【出現条件】《メインフェイズアイコン》《幻獣　ハチ》１体と《幻獣　モンキ》１体と《幻獣　キジ》１体をあなたの場からトラッシュに置く
-- 【常】：このシグニはアタックフェイズの間、バニッシュされない。
-- 【出】：あなたのデッキの上からカードを３枚エナゾーンに置く。
-- 【起】《緑》：ターン終了時まで、このシグニは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) and (x:IsCardName(1927) or x:IsCardName(1947) or x:IsCardName(1926)) end,nil,nil,nil,function(g) return g:Filter(function(x) return x:IsCardName(1927) end,nil):GetCount()>=1 and g:Filter(function(x) return x:IsCardName(1947) end,nil):GetCount()>=1 and g:Filter(function(x) return x:IsCardName(1926) end,nil):GetCount()>=1 end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_CANNOT_BANISH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function() return Duel.GetPhase()==PHASE_ATTACK end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,3)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{G}")
  e3:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_LANCER) end  -- [まで]
  end)
  c:RegisterEffect(e3)
end
