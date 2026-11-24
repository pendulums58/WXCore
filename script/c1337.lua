-- WD22-005-U フォーカラー・マイアズマ
-- 以下の４つから２つまで選ぶ。あなたのセンタールリグが＜ウリス＞の場合、代わりに３つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
-- ②あなたのトラッシュからレベル３以下のシグニ１枚を対象とし、それを場に出す。
-- ③あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
-- ④各プレイヤーは自分のデッキの上からカードを７枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local modes,targets={},{}  -- 선언 때 고른 모드와 모드마다의 대상
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local max=lc and lc:IsLrigType(LRIG_URITH) and 3 or 2
    modes={}
    for _,m in ipairs(Duel.SelectModes(tp,1,max,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do modes[m+1]=true end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    targets={}
    if modes[1] then targets[1]=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() end
    if modes[2] then targets[2]=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsLevelBetween(0,3) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() end
    if modes[3] then targets[3]=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() end
  end)
  -- 위에서부터 차례로(FAQ 2)
  e1:SetOperation(function(e,tp)
    local t={}
    for i,tc in pairs(targets) do if tc:IsRelateToEffect(e) then t[i]=tc end end
    if t[1] then aux.AddPower(e,t[1],-12000) end  -- [まで] ターン終了時まで
    if t[2] then Duel.PutOnField(t[2],tp) end
    if t[3] and t[3]:IsLocation(LOCATION_TRASH) then Duel.SendToHand(t[3]) end
    if modes[4] then
      local g=Duel.GetDecktopGroup(tp,7)
      for x in Duel.GetDecktopGroup(1-tp,7):Iter() do g:AddCard(x) end
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e1)
end
