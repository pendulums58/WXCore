-- WDK06-R08 火中取栗
-- ベット―《コインアイコン》
-- 以下の２つから１つを選ぶ。あなたがベットしていた場合、代わりに２つ選ぶ。
-- ①対象のあなたの《ライズアイコン》を持つシグニ１体よりパワーの低い対象の対戦相手のシグニ１体をバニッシュする。
-- ②あなたのデッキから《ライズアイコン》を持つシグニ１枚と＜アーム＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
s.arm=aux.ClassFilter(0,RACE_ARM)  -- ＜アーム＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  -- label: 1 = ①, 2 = ②, 3 = 둘 다
  e1:SetDeclare(function(e,tp)
    if Duel.IsBet() then
      e:SetLabel(3)
    else
      e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))+1)
    end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==2 then return end
    local rise=Duel.SelectTarget(tp,s.rise,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if rise then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<rise:GetPower() end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local mode=e:GetLabel()
    if mode~=2 then
      local mine,opp
      for tc in Duel.GetTargets():Iter() do
        if tc:IsRelateToEffect(e) then
          if tc:GetControler()==tp then mine=tc else opp=tc end
        end
      end
      if mine and opp and opp:GetPower()<mine:GetPower() then Duel.Banish(opp) end
    end
    if mode==1 then return end
    -- 《ライズアイコン》 1장과 ＜アーム＞ 1장. 둘 다인 카드는 어느 한쪽으로 센다
    Duel.SetSelectCheck(function(sg)
      if sg:GetCount()<2 then return true end
      local l={}
      for x in sg:Iter() do l[#l+1]=x end
      return (s.rise(l[1]) and s.arm(l[2])) or (s.rise(l[2]) and s.arm(l[1]))
    end)
    local g=aux.Search(tp,function(x) return s.rise(x) or s.arm(x) end,2)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
function s.rise(c) return c:IsSigni() and c:HasRiseIcon() end
