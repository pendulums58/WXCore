-- PR-238 ディストラクト・アウト（劇場版selector前売り特典3）
-- ターン終了時まで、あなたのセンタールリグは「【自】：このルリグがアタックしたとき、このルリグの下からカードを好きな枚数対象とし、このターンにあなたが《ディストラクト・アウト》以外のアーツを使用していない場合、それらをルリグトラッシュに置く。この方法でルリグトラッシュに置かれたカード１枚につき各プレイヤーは自分のデッキの上からカードを５枚トラッシュに置く。その後、あなたのデッキが０枚の場合、このルリグをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local g=Effect.CreateEffect(e:GetHandler())
    g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Ability(id,0))
    g:SetCode(EVENT_ATTACK)
    g:SetRange(LOCATION_LRIG)
    g:SetCondition(function(e2,tp2,eg) return eg:GetFirst()==e2:GetHandler() end)
    -- 0장을 골라도 덱이 0이면 업(FAQ 4). 리프레시는 처리 뒤(FAQ 2)
    g:SetOperation(function(e2,tp2)
      local h=e2:GetHandler()
      local u=Duel.SelectCards(tp2,h:GetUnderGroup(),0,99)
      local n=0
      if u:GetCount()>0 and Duel.GetArtsUsedCount(tp2)<=Duel.GetMatchingGroup(function(x) return x:IsCardName(137) end,tp2,LOCATION_LTRASH,0,nil):GetCount() then
        n=Duel.SendToLrigTrash(u,REASON_EFFECT)
      end
      for _=1,n do
        for p=0,1 do
          local d=Duel.GetDecktopGroup(p,5)
          if d:GetCount()>0 then Duel.SendToTrash(d,REASON_EFFECT) end
        end
      end
      if Duel.GetMatchingGroup(nil,tp2,LOCATION_MDECK,0,nil):GetCount()==0 then Duel.Up(h) end
    end)
    g:SetReset(RESET_PHASE+PHASE_END)
    lc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
end
