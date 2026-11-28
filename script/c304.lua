-- PR-477 ビカム・ユアセルフ（春のオールスターばとる～！ 参加賞）
-- 以下の３つから２つまで選ぶ。
-- ①このカードをあなたのセンタールリグの下に置く。
-- ②次のあなたのグロウフェイズの間、あなたのルリグがそのカードと完全に同一のルリグタイプを持つルリグにグロウする場合、グロウコストを支払わずにグロウできる。
-- ③次のあなたのグロウフェイズの間、あなたのレベル３のルリグがそのカードと完全に同一のルリグタイプを持つルリグにグロウする場合、レベルを無視してグロウできる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) local ms=Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2)) local b=0 for _,m in ipairs(ms) do b=b|(1<<m) end e:SetLabel(b) end)
  -- 「そのカード」= 센터 루리그. 완전히 같은 루리그 타입을 가진 루리그로
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if m&1~=0 and lc then Duel.PutUnder(lc,e:GetHandler()) end
    if not lc then return end
    local types=lc:GetLrigTypes()
    local same=function(e2,x)
      local t=x:GetLrigTypes()
      if #t~=#types then return false end
      for _,a in ipairs(types) do if not x:IsLrigType(a) then return false end end
      return true
    end
    local now=Duel.GetTurnCount()
    -- [の間] 次のあなたのグロウフェイズの間
    local grow=function() return Duel.GetTurnCount()==now+2 and Duel.GetPhase()==PHASE_GROW end
    for bit,code in pairs({[2]=EFFECT_GROW_COST_ZERO,[4]=EFFECT_GROW_LEVEL_FREE}) do
      if m&bit~=0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(code)
        e1:SetTargetRange(1,0)
        e1:SetTarget(same)
        e1:SetCondition(grow)
        if code==EFFECT_GROW_LEVEL_FREE then e1:SetValue(3) end
        e1:SetReset(RESET_PHASE+PHASE_END,3)
        Duel.RegisterEffect(e1,tp)
      end
    end
  end)
  c:RegisterEffect(e1)
end
