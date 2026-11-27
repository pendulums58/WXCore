-- WX09-014 黒魔姫　アンナ・スタンレー
-- 【出現条件】《メインフェイズアイコン》《悪魔姫　アンナ・ミラージュ》１体とレゾナではない＜悪魔＞のシグニ１体をあなたの場からトラッシュに置く
-- 【自】：あなたの＜悪魔＞のシグニ１体が場に出たとき、そのシグニより低いレベルを持つ対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【自】：あなたの＜悪魔＞のシグニ１体がバニッシュされたとき、そのシグニと同じレベルの対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- （このシグニが場に出たりバニッシュされたときも発動する）
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) and (x:IsCardName(1254) or (function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end)(x)) end,nil,nil,nil,function(g) return g:Filter(function(x) return x:IsCardName(1254) end,nil):GetCount()>=1 end)
  -- 자신이 나오거나 바니시돼도(괄호)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end)(x) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lv=eg:GetFirst():GetLevel()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<lv end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE+LOCATION_ENA)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() local h=e:GetHandler() return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_SZONE) and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end)(x) and (h:IsLocation(LOCATION_SZONE) or x==h) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==ev end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
