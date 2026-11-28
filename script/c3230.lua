-- WX22-005 グラン・クロス
-- 以下の３つから１つを選ぶ。
-- ①あなたのデッキから赤か青か緑の＜天使＞のシグニを合計３枚まで探して場に出し、デッキをシャッフルする。
-- ②カードを６枚引く。
-- ③対象のスペル１つの効果を打ち消す。そうした場合、対戦相手のエナゾーンから対象のカード１枚をトラッシュに置き、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    -- 스펠 컷인일 때만 ③을 고를 수 있다
    if Duel.GetCutinSpell() then
      e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1])
    else
      e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
    end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.ena=nil
    if e:GetLabel()==2 then
      s.ena=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil):GetFirst()
    end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then
      local g=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) and (x:IsColor(COLOR_RED) or x:IsColor(COLOR_BLUE) or x:IsColor(COLOR_GREEN)) end,3)
      for x in g:Iter() do Duel.PutOnField(x,tp) end
      aux.ShuffleDeck(tp)
    elseif m==1 then Duel.Draw(tp,6)
    else
      if not Duel.GetCutinSpell() then return end
      Duel.NegateSpell()
      if s.ena and s.ena:IsRelateToEffect(e) then Duel.SendToTrash(s.ena,REASON_EFFECT) end
      local t=Duel.GetDecktopGroup(tp,1):GetFirst()
      if t then Duel.SendToLife(t) end
    end
  end)
  c:RegisterEffect(e1)
end
