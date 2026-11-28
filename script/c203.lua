-- PR-328 美学の海賊　リリアナ（カードゲーマーvol.30 付録）
-- 【自】：このシグニがアタックしたとき、手札から＜武勇＞のシグニを２枚まで捨ててもよい。以下の２つから、この方法で捨てたシグニの枚数と同じ数だけ選ぶ。
-- ①このシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ②あなたのトラッシュからレベル２以下の《ライズアイコン》を持たない＜武勇＞のシグニ１枚を対象とし、それを場に出す。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  -- 같은 모드는 두 번 고를 수 없다(FAQ 1). 파워는 처리할 때(FAQ 2)
  e1:SetOperation(function(e,tp)
    local buyu=function(x) return x:IsSigni() and x:IsClass(0,RACE_BUYU) end
    local d=Duel.SelectDiscard(tp,0,2,buyu)
    if d:GetCount()==0 then return end
    Duel.SendToTrash(d,REASON_EFFECT+REASON_DISCARD)
    local n=d:GetCount()
    local modes=n>=2 and {0,1} or Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))
    local h=e:GetHandler()
    for _,m in ipairs(modes) do
      if m==0 then
        local p=h:GetPower()
        local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=p end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.Banish(tc) end
      else
        local tc=Duel.SelectTarget(tp,function(x) return buyu(x) and x:GetLevel()<=2 and not x:HasRiseIcon() end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
        if tc then Duel.PutOnField(tc,tp) end
      end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
