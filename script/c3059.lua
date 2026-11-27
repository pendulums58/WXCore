-- WX19-036 羅星　≡ホルス≡
-- 【起】《アタックフェイズアイコン》《赤》《赤》トラッシュにあるこのカードをゲームから除外する：あなたのデッキの一番上を公開する。それがレベル４のシグニの場合、それを場に出す。この能力はあなたのセンタールリグが＜カーニバル＞の場合にしか使用できない。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_TRASH)
  e1:SetEnaCost("{R}{R}")
  e1:SetTiming(TIMING_ATTACK)
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_CARNIVAL) end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_TRASH) end
    Duel.Exclude(e:GetHandler())
  end)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    local hit=(function(x) return x:IsSigni() and aux.RefLevel(tp,x)==4 end)(x)
    if hit then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
