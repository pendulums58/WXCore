-- WDK17-008 パンプキン・キャリッジ
-- 以下の２つから１つを選ぶ。
-- ①次の対戦相手のターン終了時まで、あなたのセンタールリグは対戦相手のセンタールリグのルリグタイプを追加で得る。このアーツをルリグデッキに戻す。
-- ②対戦相手のシグニを２体まで対象とし、ターン終了時まで、それらのパワーをそれぞれ－15000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil) end
  end)
  -- ②는 1체만이면 －15000만(FAQ 2)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      for tc in Duel.GetTargets():Iter() do
        if tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-15000) end  -- [まで] ターン終了時まで
      end
      return
    end
    -- [まで] 次の対戦相手のターン終了時まで(메인 페이즈 전용이라 내 턴에 쓴다)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if oc and lc then
      for _,lt in ipairs(oc:GetLrigTypes()) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_LRIG_TYPE)
        e1:SetValue(lt)
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        lc:RegisterEffect(e1)
      end
    end
    -- 처리 중에는 체크 존에 있다. 끝나고 루리그 트래시로 가기 전에 되돌린다
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_CHECK) then Duel.SendToLrigDeck(h) end
  end)
  c:RegisterEffect(e1)
end
