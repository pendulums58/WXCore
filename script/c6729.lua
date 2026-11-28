-- WXK07-031 羅星姫　アラクネ
-- 【常】：あなたのアタックフェイズの間、対戦相手の効果はバニッシュ以外であなたの＜宇宙＞のシグニを場から移動させない。
-- 【自】：このシグニがアタックしたとき、あなたのデッキを上からレベル４の＜宇宙＞のシグニが４枚めくれるまで公開してもよい。この方法でレベル４の＜宇宙＞のシグニを４枚公開した場合、ターン終了時まで、対戦相手のシグニゾーン１つを消す。公開したカードをトラッシュに置く。
-- ライフバースト：あなたのトラッシュから＜宇宙＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】「バニッシュ以外であなたの＜宇宙＞のシグニを場から移動させない」는 아직
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if not Duel.SelectYesNo(tp) then return end
    local seen=Group.CreateGroup()
    local total=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,total do
      if not ((function() local n=0 for y in seen:Iter() do if (function(y) return y:IsSigni() and y:IsClass(0,RACE_UCHU) and y:GetLevel()==4 end)(y) then n=n+1 end end return n end)()<4) then break end
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
    end
    if seen:GetCount()>0 then Duel.RevealCards(seen) end
    local ok=(function() local n=0 for y in seen:Iter() do if (function(y) return y:IsSigni() and y:IsClass(0,RACE_UCHU) and y:GetLevel()==4 end)(y) then n=n+1 end end return n end)()>=4
    if ok then
      local zs={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do zs[#zs+1]=z end
      local z=Duel.SelectZone(tp,zs)
      if z then
        Duel.RemoveZone(z)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
        e1:SetCode(EVENT_TURN_END)
        e1:SetCountLimit(1)
        e1:SetOperation(function() Duel.RestoreZone(z) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
      end
    end
    local rest=seen:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_UCHU) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e9)
end
