-- WXK07-034 ネビュラ・コネクト
-- 以下の２つから２つまで選ぶ。
-- ①このターン、あなたのデッキにあるシグニのレベルは４になる。
-- ②あなたのデッキを上からレベル４のシグニが２枚めくれるまで公開する。それらを手札に加え、残りをシャッフルしてデッキの一番下に置く。
-- ライフバースト：あなたのトラッシュから黒のシグニ１枚と黒のスペル１枚を対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1))) do
      if m==0 then
        -- [まで] このターン
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetTargetRange(LOCATION_MDECK,0)
        e1:SetTarget(function(e,x) return (Card.IsSigni)(x) end)
        e1:SetValue(4)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
      else
        local seen=Group.CreateGroup()
        local total=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
        for i=1,total do
          if not ((function() local n=0 for y in seen:Iter() do if (function(y) return y:IsSigni() and y:GetLevel()==4 end)(y) then n=n+1 end end return n end)()<2) then break end
          local last=nil
          for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
          seen:AddCard(last)
        end
        if seen:GetCount()>0 then Duel.RevealCards(seen) end
        local hit=seen:Filter(function(y) return y:IsSigni() and y:GetLevel()==4 end,nil)
        if hit:GetCount()>0 then Duel.SendToHand(hit) end
        local rest=seen:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
        if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
      end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
