-- WXEX1-68 幻獣　コザクラ
-- 【自】《ターン１回》：このシグニがアタックしたとき、あなたの＜空獣＞か＜地獣＞のシグニ１体を対象とし、手札から＜空獣＞か＜地獣＞のシグニを１枚捨ててもよい。そうした場合、それをアップする。
-- 【出】：あなたのエナゾーンから＜空獣＞か＜地獣＞のシグニを１枚まで対象とし、それを場に出す。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。②あなたのトラッシュから緑のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
local function is_ku_chi(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,is_ku_chi,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetMatchingGroup(is_ku_chi,tp,LOCATION_HAND,0,nil):GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local d=Duel.SelectDiscard(tp,1,1,is_ku_chi)
    if d:GetCount()>0 and Duel.SendToTrash(d,REASON_DISCARD+REASON_EFFECT)>0 and tc and tc:IsRelateToEffect(e) then
      Duel.Up(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,is_ku_chi,tp,LOCATION_ENA,0,0,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    e:SetLabel(m)
    if m==0 then
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
    else
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end,tp,LOCATION_TRASH,0,1,1,nil)
    end
  end)
  e9:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if e:GetLabel()==0 then Duel.Banish(tc) else Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e9)
end
