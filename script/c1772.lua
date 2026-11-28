-- WDK15-009 スティング・スイング
-- アンコール －《コインアイコン》《コインアイコン》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- あなたのトラッシュから《ライズアイコン_黒》を持つシグニ１枚と無色ではないシグニ１枚を対象とし、それらを手札に加える。
local s,id=GetID()
s.weapon=aux.ClassFilter(0,RACE_WEAPON)  -- ＜ウェポン＞のシグニ
s.rise=function(x) return x:IsSigni() and x:HasRiseIcon() and x:IsColor(COLOR_BLACK) end  -- 《ライズアイコン_黒》を持つシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)
  -- 한쪽만 있으면 그것만(FAQ 3)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local a=Duel.SelectTarget(tp,s.rise,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,a)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
end
