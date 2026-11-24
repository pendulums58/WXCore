-- WD23-012-A ブルー・サジェスト
-- 以下の３つから１つを選ぶ。あなたのセンタールリグが＜あや＞の場合、代わりに２つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをダウンし凍結する。
-- ②コストの合計が５以下のスペル１つを対象とし、それの効果を打ち消す。
-- ③対戦相手のセンタールリグの下からカードを２枚まで対象とし、それらをルリグトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local modes,tc,under={},nil,nil  -- 선언 때 고른 모드, ①의 대상, ③의 대상
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local max=lc and lc:IsLrigType(LRIG_AYA) and 2 or 1
    modes={}
    for _,m in ipairs(Duel.SelectModes(tp,1,max,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do modes[m+1]=true end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    tc,under=nil,nil
    if modes[1] then tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() end
    if modes[3] then
      local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
      local g=lc and lc:GetUnderGroup()
      if g and g:GetCount()>0 then under=Duel.SelectCards(tp,g,0,2) end  -- 쓴 플레이어가 고른다(FAQ 1)
    end
  end)
  e1:SetOperation(function(e,tp)
    if tc and tc:IsRelateToEffect(e) then
      Duel.Down(tc)
      Duel.Freeze(tc)
    end
    local sp=modes[2] and Duel.GetCutinSpell()
    if sp and sp:GetCostTotal()<=5 then Duel.NegateSpell() end  -- 카드에 적힌 코스트(FAQ 2)
    if under and under:GetCount()>0 then Duel.SendToLrigTrash(under) end
  end)
  c:RegisterEffect(e1)
end
