-- WXK10-104 フェイタル・クラウン
-- 以下の３つから１つを選ぶ。この効果をあなたのセンタールリグのレベルと同じ回数行う。
-- （他の選択肢と他のシグニを選んでもよい）
-- ①シグニ１体を対象とし、ターン終了時まで、それは【ダブルクラッシュ】と【Ｓランサー】を得る。
-- ②あなたのセンタールリグ１体を対象とし、ターン終了時まで、それは「【常】：対戦相手の効果を受けない。」を得る。
-- ③あなたのセンタールリグ１体を対象とし、ターン終了時まで、それは「【自】：このルリグがアタックしたとき、対戦相手は自分のエナゾーンのカードが２枚になるように、エナゾーンからカードをトラッシュに置く。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  -- 「…を得る」 루리그 부여 둘(②③)은 근사: ②는 아직, ③은 어택할 때 상대 에나를 2장으로
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    for i=1,(lc and lc:GetLevel() or 0) do
      local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
      if m==0 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH) aux.GrantKeyword(e,tc,EFFECT_S_LANCER) end
      elseif m==2 and lc then
        local g=Effect.CreateEffect(e:GetHandler())
        g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
        g:SetDescription(aux.Stringid(id,3))
        g:SetCode(EVENT_ATTACK)
        g:SetOperation(function(e,tp)
          local en=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ENA,0,nil)
          local k=en:GetCount()-2
          if k>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,en,k,k),REASON_EFFECT) end
        end)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_GRANT)
        e1:SetLabelObject(g)
        e1:SetReset(RESET_PHASE+PHASE_END)
        lc:GrantEffect(e1)
      end
    end
  end)
  c:RegisterEffect(e1)
end
