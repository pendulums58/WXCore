-- WX07-045 明滅の罪雅　ダエワ
-- 【出】あなたの場にある【チャーム】を好きな数トラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法でトラッシュに置いた【チャーム】１枚につき－7000する。
-- 【起】《黒》《ダウン》：あなたのトラッシュから対象のカードを３枚まで対象のあなたの好きな数の＜悪魔＞のシグニの【チャーム】にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local cg=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      if x:GetCharm() then cg:AddCard(x:GetCharm()) end
    end
    local n=cg:GetCount()>0 and Duel.SendToTrash(Duel.SelectCards(tp,cg,0,cg:GetCount()),REASON_COST) or 0
    e:SetLabel(n)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if e:GetLabel()>0 then aux.AddPower(e,tc,-7000*e:GetLabel()) end end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{B}")
  e2:SetCost(aux.SelfDownCost)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.c=Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,0,3,nil)
    s.h=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end)(x) and not x:GetCharm() end,tp,LOCATION_SZONE,0,0,3,nil)
  end)
  e2:SetOperation(function(e,tp)
    local cs={}
    for x in s.c:Iter() do if x:IsRelateToEffect(e) and x:IsLocation(LOCATION_TRASH) then cs[#cs+1]=x end end
    for h in s.h:Iter() do
      if #cs==0 then break end
      if h:IsRelateToEffect(e) and not h:GetCharm() then Duel.Charm(table.remove(cs,1),h) end
    end
  end)
  c:RegisterEffect(e2)
end
