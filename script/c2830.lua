-- WX16-003 ママ♥４　MODE２
-- 【自】：あなたか対戦相手がアーツを使用したとき、あなたは自分のエナゾーンから＜英知＞のシグニ１枚を対象とし、それがこのターンにそのプレイヤーが最初に使用したアーツだった場合、それを手札に加えるかデッキの一番上のカードをエナゾーンに置いてもよい。
-- 【起】カンニング《アタックフェイズアイコン》《コインアイコン》：あなたのシグニ１体を対象とし、それにあなたの手札からカード１枚を裏向きで付ける。そのシグニが場を離れる場合、追加でこれによって付けたカードを公開し手札に戻す。この方法でシグニを公開したとき、そのカードと同じレベルの対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg,ep) return eg:GetFirst():IsType(TYPE_ARTS) and Duel.GetArtsUsedCount(ep)==1 end)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if not x then return end
    -- 예 = 패에 넣는다, 아니오 = 덱 맨 위를 에나 존에
    if Duel.SelectYesNo(tp) then Duel.SendToHand(x) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
  -- 【起】 カンニング은 아직(근사 없음)
end
