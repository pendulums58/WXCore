-- PR-K085 起源の創鍵 ウィクロス（春のキーセレクションばとる～！ 参加賞）
-- 【常】：あなたがダメージを受ける場合、代わりにこのキーを場からルリグトラッシュに置いてもよい。
-- 【起】《ターン１回》《無×0》：以下の３つから１つを選ぶ。①あなたのデッキの上からカードを３枚見る。その中からカードを１枚まで手札に加えるかエナゾーンに置き、残りを好きな順番でデッキの一番下に置く。②対戦相手のトラッシュかルリグトラッシュからカード１枚を対象とし、それをゲームから除外する。③次の対戦相手のターンの間、対戦相手のアーツとピースとスペルの使用コストは《無×1》増える。
-- 【起】《ターン１回》ライフクロス１枚をトラッシュに置く：次の対戦相手のアタックフェイズ終了時まで、対戦相手のシグニゾーン１つを消す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DAMAGE_SUBSTITUTE)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(1,0)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH+LOCATION_LTRASH,1,1,nil) end
  end)
  e2:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then
      local g=Duel.GetDecktopGroup(tp,3)
      if g:GetCount()==0 then return end
      Duel.ConfirmCards(tp,g)
      local x=Duel.SelectCards(tp,g,0,1):GetFirst()
      if x then
        if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then Duel.SendToHand(x) else Duel.SendToEna(x) end
      end
      local r=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
      if r:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,r),false) end
    elseif m==1 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Exclude(tc) end
    else
      -- [の間] 次の対戦相手のターンの間
      local now=Duel.GetTurnCount()
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetTargetRange(0,1)
      e1:SetTarget(function(e2,x) return x:IsType(TYPE_ARTS) or x:IsType(TYPE_PIECE) or x:IsType(TYPE_SPELL) end)
      e1:SetEnaCost("{C}")
      e1:SetValue(-1)
      e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
      e1:SetReset(RESET_PHASE+PHASE_END,2)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetCountLimit(1)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetLifetopGroup(tp,1)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToTrash(g,REASON_COST)
  end)
  -- 「次の対戦相手のアタックフェイズ終了時まで」: 그 턴의 엔드 페이즈 시작에 되살린다
  e3:SetOperation(function(e,tp)
    local zs={}
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do zs[#zs+1]=z end
    local z=Duel.SelectZone(tp,zs)
    if not z then return end
    Duel.RemoveZone(z)
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE_START+PHASE_END)
    e1:SetCondition(function() return Duel.GetTurnCount()>now end)
    e1:SetCountLimit(1)
    e1:SetOperation(function() Duel.RestoreZone(z) end)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
