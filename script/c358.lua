-- WXK02-029 ビカム・ユー
-- 以下の２つから１つを選ぶ。
-- ①あなたのセンタールリグが対戦相手のセンタールリグのレベル以下の場合、あなたのセンタールリグはグロウする。ターン終了時まで、あなたのすべてのキーは能力を失う。（グロウコストは支払う）
-- ②あなたのトラッシュからあなたのセンタールリグと共通する色を持つシグニ１枚を対象とし、それを手札に加え、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() Duel.SelectTarget(tp,function(x) return x:IsSigni() and lc and x:GetColor()&lc:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
      Duel.Draw(tp,1)
      return
    end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if not (lc and oc and lc:GetLevel()<=oc:GetLevel()) then return end
    -- 그로우 코스트는 낸다
    local function ok(x)
      if not (x:IsType(TYPE_LRIG) and x:GetLevel()==lc:GetLevel()+1 and Duel.CanPayEna(tp,x:GetEnaCost())) then return false end
      for _,lt in ipairs(lc:GetLrigTypes()) do if x:IsLrigType(lt) then return true end end
      return false
    end
    local g=Duel.GetMatchingGroup(ok,tp,LOCATION_LDECK,0,nil)
    if g:GetCount()>0 then Duel.Grow(Duel.SelectCards(tp,g,1,1):GetFirst(),tp) end
    -- [まで] ターン終了時まで
    for k in Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil):Iter() do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      k:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
