-- WX17-Re14 コードアート　†Ａ・Ｌ・Ｃ・Ａ†
-- 【出】手札から＜電機＞のシグニを１枚捨てる：以下の３つから１つを選ぶ。
-- ①対戦相手のシグニ２体を対象とし、ターン終了時まで、それらのパワーをそれぞれ－2000する。
-- ②あなたのデッキの上からカードを２枚トラッシュに置く。その後、あなたのトラッシュからあなたのセンタールリグと共通する色を持つシグニ１枚を対象とし、それを手札に加える。
-- ③あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュから黒のスペル１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1])
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then
      for tc in Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,2,2,nil):Iter() do aux.AddPower(e,tc,-2000) end  -- [まで]
      return
    end
    local g=Duel.GetDecktopGroup(tp,m==1 and 2 or 3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local f=m==1 and function(x) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return x:IsSigni() and lc and x:GetColor()&lc:GetColor()~=0 end or function(x) return x:IsType(TYPE_SPELL) and x:IsColor(COLOR_BLACK) end
    local x=Duel.SelectTarget(tp,f,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
end
