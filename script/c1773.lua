-- WDK15-011 弩書　トート
-- 【ライズ】あなたの＜ウェポン＞のシグニ１体の上に置く
-- 【常】：このシグニはこの下にカードが３枚以上あるかぎり、【ダブルクラッシュ】を得る。
-- 【常】：このシグニのパワーはこの下にあるカード１枚につき＋1000される。
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、対戦相手のすべてのシグニのパワーをこのシグニのパワーの半分だけ－（マイナス）する。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
s.weapon=aux.ClassFilter(0,RACE_WEAPON)  -- ＜ウェポン＞のシグニ
s.rise=function(x) return x:IsSigni() and x:HasRiseIcon() and x:IsColor(COLOR_BLACK) end  -- 《ライズアイコン_黒》を持つシグニ
function s.initial_effect(c)
  aux.AddRise(c,s.weapon)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 【チャーム】 등은 세지 않는다(FAQ 4)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetUnderGroup():GetCount()>=3 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetValue(function(e) return 1000*e:GetHandler():GetUnderGroup():GetCount() end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ATTACK)
  -- 수정이 모두 끝난 파워의 반(FAQ 2)
  e3:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    local v=h:GetPower()//2
    if v<=0 then return end
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-v) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e4)
end
