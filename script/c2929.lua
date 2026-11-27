-- WX17-044 ＡＲＲＯＷ　ＲＡＩＮ
-- あなたのデッキの上からカードを５枚見て好きな枚数を【トラップ】としてあなたのシグニゾーンに設置し、残りをトラッシュに置く。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《青》《無》：あなたの【トラップ】１つを対象とし、トラッシュにあるこのカードをゲームから除外する。そうした場合、それを表向きにし《トラップアイコン》を発動させる。
-- 【トラップアイコン】：アタックしているシグニ１体を対象とし、あなたのライフクロスが２枚以下の場合、《青》を支払ってもよい。そうした場合、それはこのアタックでダメージを与えない。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    for x in Duel.SelectCards(tp,g,0,5):Iter() do Duel.SetTrap(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRASH)
  e2:SetEnaCost("{U}{C}")
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRAP,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_TRASH) or Duel.Exclude(h)==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.OpenTrap(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_TRAP)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()>2 then return end
    if Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_PREVENT_DAMAGE)
      e1:SetTargetRange(1,0)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)  -- 「このアタックでダメージを与えない」: 다음 대미지 1번 방지(근사)
    end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e4:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e4)
end
