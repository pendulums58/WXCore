-- WX10-023 ブラック・コフィン
-- 以下の２つから１つを選ぶ。
-- ①あなたのトラッシュからあなたのセンタールリグと共通する色を持つシグニ１枚を対象とし、それを手札に加える。
-- ②対戦相手のトラッシュにあるスペル１枚を対象とし、それをゲームから除外する。このゲームの間、対戦相手はそれと同じ名前のカードを使用できない。（カットインされたスペルはこの効果の影響を受けない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and lc and x:IsColor(lc:GetColor()) end,tp,LOCATION_TRASH,0,1,1,nil)
    else
      Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,0,LOCATION_TRASH,1,1,nil)
    end
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if e:GetLabel()==0 then
      Duel.SendToHand(tc)
      return
    end
    local cid=tc:GetCode()
    Duel.Exclude(tc)
    -- 「このゲームの間」 같은 이름의 카드를 쓸 수 없다
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_USE)
    e1:SetTargetRange(0,1)
    e1:SetTarget(function(e,x) return x:IsCardName(cid) end)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
