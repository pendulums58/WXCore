-- SP23-009 真剣焦舞（「Lostorage incited WIXOSS 1」 初回特典）
-- 以下の２つから１つを選ぶ。
-- ①ターン終了時まで、《ライズアイコン》を持つあなたのすべてのシグニは【ダブルクラッシュ】を得る。
-- ②あなたの場にある《ライズアイコン》を持つシグニ１体につきカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- 쓴 때 장에 있는 것만(FAQ 1). 아래에 겹친 카드는 세지 않는다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil)
    if e:GetLabel()==0 then
      for x in g:Iter() do aux.GrantKeyword(e,x,EFFECT_DOUBLE_CRUSH) end  -- [まで] ターン終了時まで
    elseif g:GetCount()>0 then
      Duel.Draw(tp,g:GetCount())
    end
  end)
  c:RegisterEffect(e1)
end
