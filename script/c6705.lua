-- WXK07-002 千変万化
-- あなたのセンタールリグが＜メル＞の場合、このアーツの使用コストは《緑×2》減る。
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。
-- ②【アサシン】か【ダブルクラッシュ】を持つシグニ１体を対象とし、それをバニッシュする。
-- ③あなたのデッキの上からカードを３枚公開する。その中からすべての緑のカードを手札に加え、残りを好きな順番でデッキの一番下に置く。
-- ④このターン、次にあなたがダメージを受ける場合、代わりにダメージを受けない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do
      if m==0 then
        local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.Banish(tc) end
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:HasKeyword(EFFECT_ASSASSIN) or x:HasKeyword(EFFECT_DOUBLE_CRUSH)) end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.Banish(tc) end
      elseif m==2 then
        local g=Duel.GetDecktopGroup(tp,3)
        if g:GetCount()>0 then
          Duel.RevealCards(g)
          local gr=g:Filter(function(x) return x:IsColor(COLOR_GREEN) end,nil)
          if gr:GetCount()>0 then Duel.SendToHand(gr) end
          local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
          if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
        end
      else
        -- [まで] このターン、次に
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_PREVENT_DAMAGE)
        e1:SetTargetRange(1,0)
        e1:SetCountLimit(1)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
      end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_MEL) end)() then return Duel.ReduceCost(base,"{G}{G}",1) end return base end)
end
