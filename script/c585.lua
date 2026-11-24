-- WD14-014 堕落の才女　ルシファル
-- 【自】：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
-- 【出】《黒》《黒》《黒》：あなたのトラッシュからレベル３以下の＜悪魔＞のシグニを２枚まで対象とし、それらを場に出す。
-- ライフバースト：どちらか１つを選ぶ。①すべての＜天使＞のシグニをバニッシュする。②あなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}{B}{B}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) and x:GetLevel()<=3 end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
      Duel.Banish(Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_TENSHI),tp,LOCATION_SZONE,LOCATION_SZONE,nil))
      return
    end
    local tc=Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_AKUMA),tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if not tc then return end
    if Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e3)
end
