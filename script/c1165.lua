-- WD07-018 スラッシュ・ミラクル
-- 以下の２つから１つを選ぶ。
-- ①あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。
-- ライフバースト：どちらか１つを選ぶ。①あなたのデッキから白のシグニ１枚を探して場に出し、デッキをシャッフルする。
--   ②あなたのトラッシュから黒のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- 모드는 사용 선언 때 고르고 바꿀 수 없다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      aux.SearchToHand(tp,Card.IsSigni,1)
      return
    end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-8000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(s.lbop)
  c:RegisterEffect(e2)
end
function s.white(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end
function s.black(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end
function s.lbop(e,tp)
  if Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
    local tc=Duel.SelectCards(tp,Duel.GetMatchingGroup(s.white,tp,LOCATION_MDECK,0,nil),0,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
    Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
    return
  end
  local tc=Duel.SelectTarget(tp,s.black,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
  if tc then Duel.PutOnField(tc,tp) end
end
