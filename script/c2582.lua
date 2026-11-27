-- WX12-CB02 幻獣　ぷにとー
-- 【自】：あなたのアタックフェイズ開始時、あなたのデッキの一番上を公開する。
-- それがレベル１のシグニの場合、ターン終了時まで、このシグニのパワーを＋5000する。レベル２の場合、あなたのデッキの一番上のカードをエナゾーンに置く。レベル３の場合、ターン終了時まで、このシグニは【ランサー】を得る。レベル４の場合、カードを１枚引く。レベル５の場合、対象の対戦相手のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,1)):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if not x:IsSigni() then return end
    local h,lv=e:GetHandler(),x:GetLevel()
    if lv==1 and h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,5000)
    elseif lv==2 then Duel.EnaCharge(tp,1)
    elseif lv==3 and h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_LANCER)
    elseif lv==4 then Duel.Draw(tp,1)
    elseif lv==5 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
end
