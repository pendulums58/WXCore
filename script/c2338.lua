-- WX09-012 ブルーコードハート　Ｖ・＠・Ｃ
-- 【出現条件】 《メインフェイズアイコン》　《コードハート　Ｖ・Ａ・Ｃ》１体とレゾナではない＜電機＞のシグニ１体をあなたの場からトラッシュに置く
-- 【自】：あなたが青のスペルを使用したとき、シグニ１体を対象とし、それをアップする。
-- 【出】：あなたのトラッシュからコストの合計が３以下の青のスペル１枚を対象とし、それをコストを支払わずに使用してもよい。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) and (x:IsCardName(1280) or (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end)(x)) end,nil,nil,nil,function(g) return g:Filter(function(x) return x:IsCardName(1280) end,nil):GetCount()>=1 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) local x=eg:GetFirst() return ep==tp and x:IsType(TYPE_SPELL) and x:IsColor(COLOR_BLUE) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Up(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) and x:IsColor(COLOR_BLUE) and x:GetCostTotal()<=3 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.SelectYesNo(tp) then Duel.UseFree(tc,tp) end end
  end)
  c:RegisterEffect(e2)
end
