-- WDK12-007 難攻不落
-- ベット―《コインアイコン》《コインアイコン》（このアーツを使用する際に《コインアイコン》を支払ってもよい）
-- 以下の２つから１つを選ぶ。あなたがベットしていた場合、代わりに２つ選ぶ。
-- ①あなたのトラッシュから対象の＜微菌＞のシグニ１枚を対象のあなたのシグニ１体の【チャーム】にする。ターン終了時まで、【チャーム】が付いているあなたのすべてのシグニは「【常】：対戦相手のターンの間、バニッシュされない。」を得る。
-- ②あなたの場にあるすべての【チャーム】をトラッシュに置く。この方法でトラッシュに置いた【チャーム】と同じ数だけカードを引き、同じ数だけ【エナチャージ１】をする。
local s,id=GetID()
s.germ=aux.ClassFilter(0,RACE_BIKIN)  -- ＜微菌＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetDeclare(s.mode)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- label: 1 = ①, 2 = ②, 3 = 둘 다(ベット)
function s.mode(e,tp)
  if Duel.IsBet() then
    e:SetLabel(3)
  else
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 and 1 or 2)
  end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  if e:GetLabel()~=2 then
    Duel.SelectTarget(tp,s.germ,tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,LOCATION_SZONE,0,1,1,nil)
  end
end
-- 【チャーム】을 붙인 뒤에 조건을 본다(FAQ 1). 배틀·룰 처리 바니시도 막는다(FAQ 2)
function s.op(e,tp)
  local mode=e:GetLabel()
  if mode~=2 then
    local ch,host
    for tc in Duel.GetTargets():Iter() do
      if tc:IsLocation(LOCATION_TRASH) then ch=ch or tc elseif tc:IsLocation(LOCATION_SZONE) then host=host or tc end
    end
    if ch and host and ch:IsRelateToEffect(e) and host:IsRelateToEffect(e) and not host:GetCharm() then Duel.Charm(ch,host) end
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,LOCATION_SZONE,0,nil):Iter() do
      -- [まで] ターン終了時まで
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CANNOT_BANISH)
      e1:SetCondition(function(ef) return Duel.GetTurnPlayer()~=ef:GetHandler():GetControler() end)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end
  if mode~=1 then
    local g=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,LOCATION_SZONE,0,nil):Iter() do g:AddCard(x:GetCharm()) end
    local n=g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT) or 0
    -- 덱이 모자라면 놓을 수 있는 만큼만(FAQ 3)
    if n>0 then
      Duel.Draw(tp,n)
      Duel.EnaCharge(tp,n)
    end
  end
end
