-- WX17-001 カーニバル　―Ｑ―
-- 【常】：《カーニバル　―Ｑ―》は自身以外の効果を受けない。
-- 【自】：このルリグがアタックしたとき、以下の４つから１つを選ぶ。
-- ①カードを１枚引く。②あなたのデッキの一番上のカードをエナゾーンに置く。
-- ③ターン終了時まで、このルリグは【ダブルクラッシュ】を得る。
-- ④対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- 【起】ジョーカー《アタックフェイズアイコン》《コインアイコン》：ターン終了時まで、対象のあなたのシグニ１体はあなたのトラッシュにある対象のシグニ１枚と同じカードになる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_LRIG)
  e1:SetValue(function(e,sc) return sc~=e:GetHandler() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    local m=Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))[1]
    local h=e:GetHandler()
    if m==0 then Duel.Draw(tp,1)
    elseif m==1 then Duel.EnaCharge(tp,1)
    elseif m==2 then aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH)
    else
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.SendToTrash(tc,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e2)
  -- 【起】 ジョーカー(「同じカードになる」)는 아직(근사 없음)
end
