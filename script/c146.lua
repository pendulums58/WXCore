-- WX17-Re05 チャーム・タクティクス
-- アンコール －《無》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- 以下の２つから１つを選ぶ。
-- ①あなたのシグニを２体まで対象とし、あなたのデッキの上からカード２枚をそれらの【チャーム】にする。
-- ②対戦相手のシグニを２体まで対象とし、対戦相手のデッキの上からカード２枚をそれらの【チャーム】にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncoreCost("{C}")
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    local p=e:GetLabel()==0 and tp or 1-tp
    local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,p==tp and LOCATION_SZONE or 0,p==tp and 0 or LOCATION_SZONE,0,2,nil)
    for x in g:Iter() do
      local top=Duel.GetDecktopGroup(p,1):GetFirst()
      if top and x:IsRelateToEffect(e) then Duel.Charm(top,x) end
    end
  end)
  c:RegisterEffect(e1)
end
