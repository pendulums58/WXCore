-- WX12-017 ダークアート　†Ｍ・Ｇ・Ｔ†
-- 【出現条件】 《メインフェイズアイコン》レゾナではない青の＜電機＞のシグニ１体とレゾナではない黒の＜電機＞のシグニ１体をあなたの場からトラッシュに置く
-- 【自】：対戦相手のアタックフェイズ開始時、対戦相手のシグニ１体を対象とし、手札からスペルを１枚捨ててもよい。そうした場合、それをダウンし凍結する。
-- 【出】：あなたのトラッシュから青か黒のスペル１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) and x:IsClass(0,RACE_DENKI) end,nil,nil,nil,function(g)
    local u,b=false,false
    for x in g:Iter() do
      if x:IsColor(COLOR_BLUE) and not u then u=true elseif x:IsColor(COLOR_BLACK) then b=true end
    end
    return u and b
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    if Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) and (x:IsColor(COLOR_BLUE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
