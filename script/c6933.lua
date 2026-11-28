-- WXK09-060 楽隊の童話　コケコブ
-- 【ライズ】あなたの《楽隊の童話　ロバン》１体の上に置く
-- 【自】：あなたのアタックフェイズ開始時、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこのシグニの下にあるカード１枚につき－4000する。
-- 【自】：対戦相手のターンの間、このシグニが場を離れたとき、対戦相手のデッキの上からカードを４枚トラッシュに置く。
-- 【出】：あなたのトラッシュから《楽隊の童話　キャットレ》１枚と《楽隊の童話　ドッグメ》１枚を対象とし、それらをこのシグニの下に置く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsCardName(6966) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-4000*e:GetHandler():GetUnderGroup():GetCount())
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(1-tp,4)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsCardName(6973) end,tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsCardName(6970) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if h:IsLocation(LOCATION_SZONE) and g:GetCount()>0 then Duel.PutUnder(h,g) end
  end)
  c:RegisterEffect(e3)
end
