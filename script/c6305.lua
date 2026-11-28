-- WXK02-028 ミュウ＝ベルベット
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【自】：このルリグがアタックしたとき、あなたのトラッシュからあなたのセンタールリグと同じレベルのシグニ１枚を対象とし、《無》を支払ってもよい。そうした場合、それを手札に加える。
-- 【起】《ターン１回》エクシード１（あなたのルリグの下からカードを１枚ルリグトラッシュに置く）：対戦相手のシグニ１体を対象とし、あなたのデッキからそれぞれレベルの異なるシグニ４枚を探してトラッシュに置き、デッキをシャッフルする。この方法でカードを４枚トラッシュに置いた場合、ターン終了時まで、それのパワーを－12000する。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Ability(id,1))
    g:SetCode(EVENT_ATTACK)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      local lv=lc and lc:GetLevel() or -1
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,LOCATION_TRASH,0,1,1,nil)
    end)
    g:SetOperation(function(e,tp)
      local tc=Duel.GetFirstTarget()
      if not (tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{C}") and Duel.SelectYesNo(tp)) then return end
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{C}"),REASON_COST)
      if tc:IsLocation(LOCATION_TRASH) then Duel.SendToHand(tc) end
    end)
    local e91=Effect.CreateEffect(c)
    e91:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e91:SetDescription(aux.Ability(id,0))
    e91:SetCode(EFFECT_GRANT)
    e91:SetRange(LOCATION_KEY)
    e91:SetTargetRange(LOCATION_LRIG,0)
    e91:SetLabelObject(g)
    c:RegisterEffect(e91)
  end
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,2))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(1)
    g:SetCountLimit(1)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    end)
    g:SetOperation(function(e,tp)
      -- 정확히 레벨이 다른 4장(FAQ 1). 모자라면 1장도 두지 않는다
      local tc=Duel.GetFirstTarget()
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_MDECK,0,nil)
      local picked=Group.CreateGroup()
      local lv,k={},0
      for x in g:Iter() do if not lv[x:GetLevel()] then lv[x:GetLevel()]=true k=k+1 end end
      if k>=4 then
        Duel.SetSelectCheck(function(sg) return sg:GetCount()==0 or (sg:GetCount()==4 and aux.DistinctLevels(sg)) end)
        picked=Duel.SelectCards(tp,g,0,4)
      end
      local n=picked:GetCount()==4 and Duel.SendToTrash(picked,REASON_EFFECT) or 0
      aux.ShuffleDeck(tp)
      if n==4 and tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-12000) end
    end)
    local e92=Effect.CreateEffect(c)
    e92:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e92:SetDescription(aux.Ability(id,0))
    e92:SetCode(EFFECT_GRANT)
    e92:SetRange(LOCATION_KEY)
    e92:SetTargetRange(LOCATION_LRIG,0)
    e92:SetLabelObject(g)
    c:RegisterEffect(e92)
  end
end
