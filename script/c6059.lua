-- WXEX1-25 悲壮の駄姫　グズ子
-- 【自】《ターン１回》：あなたの＜遊具＞のシグニ１体がトラッシュから場に出たとき、あなたのトラッシュからそのシグニより低いレベルを持つ＜遊具＞のシグニ１枚を対象とし、あなたのターンの場合、それを場に出す。
-- 【出】：あなたのデッキの上からカードを５枚見る。その中から１枚を手札に加え、１枚をトラッシュに置き、残りを好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    return eg:Filter(function(x) return x:IsSigni() and x:GetControler()==tp and x:IsClass(0,RACE_YUGU) and x:IsPreviousLocation(LOCATION_TRASH) end,nil):GetCount()>0
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local sc=eg:Filter(function(x) return x:IsSigni() and x:GetControler()==tp and x:IsClass(0,RACE_YUGU) and x:IsPreviousLocation(LOCATION_TRASH) end,nil):GetFirst()
    if not sc then return end
    local lv=sc:GetLevel()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) and x:GetLevel()<lv end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if Duel.GetTurnPlayer()~=tp then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local p1=Duel.SelectCards(tp,g,1,1)
    if p1:GetCount()>0 then Duel.SendToHand(p1) end
    local rem1=g:Filter(function(x) return not p1:IsContains(x) end,nil)
    local p2=Duel.SelectCards(tp,rem1,1,1)
    if p2:GetCount()>0 then Duel.SendToTrash(p2,REASON_EFFECT) end
    local rest=rem1:Filter(function(x) return not p2:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e2)
end
