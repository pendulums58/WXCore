-- PR-204 アーク・ディストラクト（劇場版selector前売り特典１）
-- このカードはあなたのセンタールリグがレベル４以下の場合にしか使用できない。
-- ターン終了時まで、あなたのセンタールリグは「【自】：このルリグがアタックしたとき、このターンにあなたが《アーク・ディストラクト》以外のアーツを使用していない場合、このルリグの下からカードを２枚ルリグトラッシュに置いてもよい。そうした場合、このルリグをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()<=4 end)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local g=Effect.CreateEffect(e:GetHandler())
    g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Ability(id,0))
    g:SetCode(EVENT_ATTACK)
    g:SetRange(LOCATION_LRIG)
    g:SetCondition(function(e2,tp2,eg) return eg:GetFirst()==e2:GetHandler() end)
    -- 상대가 쓴 아츠는 세지 않는다(FAQ 2). 이 카드 자신만 썼으면 1장
    g:SetOperation(function(e2,tp2)
      local h=e2:GetHandler()
      if Duel.GetArtsUsedCount(tp2)>Duel.GetMatchingGroup(function(x) return x:IsCardName(118) end,tp2,LOCATION_LTRASH,0,nil):GetCount() then return end
      local u=h:GetUnderGroup()
      if u:GetCount()<2 or not Duel.SelectYesNo(tp2) then return end
      Duel.SendToLrigTrash(Duel.SelectCards(tp2,u,2,2),REASON_EFFECT)
      Duel.Up(h)
    end)
    g:SetReset(RESET_PHASE+PHASE_END)
    lc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
end
