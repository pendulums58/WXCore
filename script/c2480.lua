-- WX11-028 弩砲　ゴルドガン
-- 【自】：あなたの＜ウェポン＞のシグニが対戦相手のライフクロス１枚をクラッシュしたとき、カードを１枚引く。
-- 【出】：あなたのデッキの上からカードを３枚トラッシュに置く。その後、この方法でトラッシュに置かれたカードの中に、共通するレベルを持つシグニが２枚以上ある場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) local c=Duel.GetCrusher() return ep~=tp and c and c:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)(c) end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local lv={}
    local hit=false
    for x in g:Iter() do
      if x:IsSigni() and x:IsLocation(LOCATION_TRASH) then
        if lv[x:GetLevel()] then hit=true end
        lv[x:GetLevel()]=true
      end
    end
    if not hit then return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
