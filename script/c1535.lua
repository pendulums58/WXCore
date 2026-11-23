-- WDK-F03-10 ヴィクティム・ディフェンス
-- ベット―《コインアイコン》
-- 以下の２つから１つを選ぶ。あなたがベットしていた場合、代わりに２つ選ぶ。
-- ①対戦相手のシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。手札を２枚捨てる。（手札が１枚以下で使用した場合すべて捨てる）
-- ②あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetDeclare(s.mode)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- label: 1 = ①, 2 = ②, 3 = 둘 다. ベット하면 ②의 대상도 먼저 고르고 ①부터 처리한다(①로 버린 시그니는 ②로 못 가져온다. FAQ 2)
-- 모드는 ベット 뒤, 코스트 전에 고른다
function s.mode(e,tp)
  if Duel.IsBet() then
    e:SetLabel(3)
  else
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 and 1 or 2)
  end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local mode=e:GetLabel()
  if mode~=2 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  if mode~=1 then Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil) end
end
function s.op(e,tp)
  local mode=e:GetLabel()
  local field, trash
  for tc in Duel.GetTargets():Iter() do
    if tc:IsLocation(LOCATION_SZONE) then field=field or tc
    elseif tc:IsLocation(LOCATION_TRASH) then trash=trash or tc end
  end
  if mode~=2 then
    if field and field:IsRelateToEffect(e) then
      -- [まで] ターン終了時まで 「アタックできない」를 얻는다
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CANNOT_ATTACK)
      e1:SetReset(RESET_PHASE+PHASE_END)
      field:GrantEffect(e1)
    end
    local hand=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
    local n=math.min(2,hand)
    if n>0 then Duel.SendToTrash(Duel.SelectDiscard(tp,n,n),REASON_EFFECT+REASON_DISCARD) end
  end
  if mode~=1 and trash and trash:IsRelateToEffect(e) then Duel.SendToHand(trash) end
end
