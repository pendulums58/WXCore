-- WXK08-003 グリモワール・ブラスト
-- あなたのセンタールリグが＜ナナシ＞の場合、このアーツの使用コストは《黒×2》減る。
-- 以下の３つから２つまで選ぶ。
-- ①あなたのトラッシュからシグニ１枚を対象とし、それを【ライズ】を無視して場に出す。それの【出】能力は発動しない。
-- ②対戦相手のレベル３以下のシグニ１体を対象とし、それをバニッシュする。
-- ③対戦相手のシグニ１体を対象とし、このターンに対戦相手がアーツかスペルを使用していた場合、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
      if m==0 then
        -- 「【ライズ】を無視して」(근사: 보통 장에 내기)
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
        if tc then Duel.PutOnField(tc,tp,true) end
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.Banish(tc) end
      else
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc and Duel.GetArtsUsedCount(1-tp)+Duel.GetSpellsUsedCount(1-tp)>0 then Duel.SendToTrash(tc,REASON_EFFECT) end
      end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_NANASHI) end)() then return Duel.ReduceCost(base,"{B}{B}",1) end return base end)
end
