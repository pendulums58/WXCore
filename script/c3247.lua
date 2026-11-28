-- WX22-025 天空の主神　ゼウシアス
-- 【常】：【マルチエナ】
-- 【常】：【シャドウ】
-- 【常】：このシグニはすべての色を得る。
-- 【自】《ターン１回》：このシグニがアタックしたとき、対戦相手が、対象の自分のシグニ１体を場からトラッシュに置くか、自分の手札を２枚捨てるか、対象の自分のエナゾーンからカード３枚をトラッシュに置かないかぎり、対戦相手にダメージを与える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 셋
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_SHADOW)
  e2:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e2)
  -- [の間] 【常】 장에 있을 때만 모든 색을 얻는다 (FAQ 3)
  local e2b=Effect.CreateEffect(c)
  e2b:SetType(EFFECT_TYPE_SINGLE)
  e2b:SetDescription(aux.Ability(id,2))
  e2b:SetCode(EFFECT_ADD_COLOR)
  e2b:SetRange(LOCATION_SZONE)
  e2b:SetValue(COLOR_WHITE|COLOR_RED|COLOR_BLUE|COLOR_GREEN|COLOR_BLACK)
  c:RegisterEffect(e2b)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ATTACK)
  e3:SetCountLimit(1)
  e3:SetOperation(function(e,tp)
    local o=1-tp
    -- 상대: 실행할 수 있는 선택지만 제시(FAQ 5, 6, 8)
    local opts,acts={},{}
    if Duel.GetMatchingGroup(Card.IsSigni,o,LOCATION_SZONE,0,nil):GetCount()>=1 then
      opts[#opts+1]=aux.Stringid(id,0); acts[#acts+1]=0
    end
    if Duel.GetMatchingGroup(nil,o,LOCATION_HAND,0,nil):GetCount()>=2 then
      opts[#opts+1]=aux.Stringid(id,1); acts[#acts+1]=1
    end
    if Duel.GetMatchingGroup(nil,o,LOCATION_ENA,0,nil):GetCount()>=3 then
      opts[#opts+1]=aux.Stringid(id,2); acts[#acts+1]=2
    end
    opts[#opts+1]=aux.Stringid(id,3); acts[#acts+1]=3
    local m=acts[Duel.SelectOption(o,table.unpack(opts))+1]
    if m==0 then
      local tc=Duel.SelectTarget(o,Card.IsSigni,o,LOCATION_SZONE,0,1,1,nil):GetFirst()
      if tc and Duel.SendToTrash(tc,REASON_EFFECT)>0 then return end
    elseif m==1 then
      if aux.Discard(o,2)>0 then return end
    elseif m==2 then
      local g=Duel.SelectTarget(o,nil,o,LOCATION_ENA,0,3,3,nil)
      if g:GetCount()==3 and Duel.SendToTrash(g,REASON_EFFECT)>0 then return end
    end
    Duel.Damage(o)
  end)
  c:RegisterEffect(e3)
end
