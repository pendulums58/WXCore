-- WXK10-038 大装　ライブレラ
-- 【出】手札からシグニを１枚捨てる：あなたのトラッシュからこの方法で捨てたシグニと共通するクラスを持ち《ライズアイコン》を持つシグニ１枚を対象とし、それを手札に加える。
-- 【起】《ダウン》：《ライズアイコン》を持つあなたのシグニ１体を対象とし、ターン終了時まで、それは【アサシン】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_HAND,0,nil)
    if chk==0 then return g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    s.dc=x
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp,eg)
    local d0=s.dc
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasRiseIcon() and x~=d0 and (function(a,b) local g=Group.CreateGroup() g:AddCard(a) g:AddCard(b) return aux.ShareClass(g) end)(x,d0) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.SelfDownCost)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.GrantKeyword(e,tc,EFFECT_ASSASSIN)
    end
  end)
  c:RegisterEffect(e2)
end
