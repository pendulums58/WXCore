-- WD21-009 燐廻転生
-- ターン終了時まで、あなたのセンタールリグは「【自】：このルリグがアタックしたとき、このルリグの下からカードを好きな枚数対象とし、それらをルリグトラッシュに置く。その後、この方法で２枚以上のカードをルリグトラッシュに置いた場合、数字２つを宣言する。このターン、対戦相手は宣言された数字と同じレベルのシグニで【ガード】ができない。４枚以上の場合、ターン終了時まで、このルリグは【トリプルクラッシュ】を得る。５枚以上の場合、このルリグをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    -- [まで] ターン終了時まで
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetDescription(aux.Ability(id,0))
    e2:SetCode(EVENT_ATTACK)
    e2:SetReset(RESET_PHASE+PHASE_END)
    e2:SetOperation(s.op)
    lc:GrantEffect(e2)
  end)
  c:RegisterEffect(e1)
end
-- 2장·4장·5장 이상의 처리를 순서대로 모두 한다(FAQ 3)
function s.op(e,tp)
  local c=e:GetHandler()
  if not c:IsLocation(LOCATION_LRIG) then return end
  local g=c:GetUnderGroup()
  if g:GetCount()==0 then return end
  local n=Duel.SendToLrigTrash(Duel.SelectCards(tp,g,0,g:GetCount()))
  if n<2 then return end
  -- [の間] 「このターン」
  for _,lv in ipairs{Duel.AnnounceNumber(tp,0,5),Duel.AnnounceNumber(tp,0,5)} do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_GUARD)
    e1:SetTargetRange(0,1)
    e1:SetValue(lv)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end
  if n>=4 then aux.GrantKeyword(e,c,EFFECT_TRIPLE_CRUSH) end  -- [まで] ターン終了時まで
  if n>=5 then Duel.Up(c) end
end
