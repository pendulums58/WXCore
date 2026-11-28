-- WXK04-010 アンコール・シード
-- アンコール －《コインアイコン》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- あなたのデッキの上からカードを４枚見る。その中からカードを２枚まで【シード】としてあなたのシグニゾーンに出し、残りをシャッフルしてデッキの一番下に置く。
-- （【シード】であるカードはシグニゾーン１つにつき１枚まで裏向きで置くことができ、開花することでシグニになる）
-- （すでに【シード】のあるシグニゾーンに【シード】を出す場合、元からある【シード】をトラッシュに置いてから出す）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(1)
  e1:SetOperation(function(e,tp,eg)
    -- 이미 【シード】가 있는 존이면 원래 것은 트래시로(카드 주석)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    for x in Duel.SelectCards(tp,g,0,2):Iter() do Duel.SetSeed(x,tp) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
end
