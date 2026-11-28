-- PR-459A トライ・ラック（ウィクロスマガジンvol.9 付録）
-- 対戦相手の手札を１枚見ないで選び、対戦相手はそのカードを公開する。その後、そのカードがレベル１のシグニの場合、あなたのデッキの上からカードを３枚エナゾーンに置く。
-- レベル２のシグニの場合、あなたはカードを３枚引く。
-- レベル３のシグニの場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- レベル４のシグニの場合、対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- レベル５のシグニの場合、あなたは手札を１枚捨てる。
-- スペルの場合、対戦相手はそのカードを捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 패가 없으면 아무 일도 없다(FAQ 1). 대상은 공개한 뒤에 고른다(FAQ 4)
  e1:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    local x=h:GetCount()>0 and Duel.SelectCards(tp,h,1,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    if x:IsType(TYPE_SPELL) then
      Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD)
    elseif x:IsSigni() then
      local lv=x:GetLevel()
      if lv==1 then
        local g=Duel.GetDecktopGroup(tp,3)
        if g:GetCount()>0 then Duel.SendToEna(g) end
      elseif lv==2 then
        Duel.Draw(tp,3)
      elseif lv==3 or lv==4 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then
          if lv==3 then Duel.Banish(tc) else Duel.SendToTrash(tc,REASON_EFFECT) end
        end
      elseif lv==5 then
        aux.Discard(tp,1)
      end
    end
  end)
  c:RegisterEffect(e1)
end
