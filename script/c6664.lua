-- WXK06-049 幻竜　ディナモ
-- 【常】：このシグニのパワーが8000以上であるかぎり、このシグニによってバニッシュされたシグニはエナゾーンに置かれる代わりにトラッシュに置かれる。
-- 【常】：このシグニはパワーが12000以上であるかぎり、【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
-- 【起】手札から＜龍獣＞のシグニを１枚捨てる：ターン終了時まで、このシグニのパワーをこの方法で捨てたシグニのパワーと同じだけ＋（プラス）する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_KILL_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetPower()>=8000 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_LANCER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return e:GetHandler():GetPower()>=12000 end)
  c:RegisterEffect(e2)
  local pw=0
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return h:GetCount()>0 end
    local x=Duel.SelectCards(tp,h,1,1):GetFirst()
    pw=x:GetPower()
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e3:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,pw) end
  end)
  c:RegisterEffect(e3)
end
