-- WXEX1-11 エルドラ×マークⅣ　ＨＹＰＥＲ
-- 【常】：あなたのすべての領域にある＜水獣＞のカードは【ライフバースト】「どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のシグニ１体を対象とし、それをダウンする。」を得る。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《コインアイコン》：対戦相手のライフクロスの上からカードを２枚見る。あなたはその中から１枚をあなたのチェックゾーンに置き、残りを対戦相手のライフクロスの一番上に戻す。あなたはそのライフバーストを発動させる。そのカードをトラッシュに置き、対戦相手はデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local lb=Effect.CreateEffect(c)
  lb:SetType(EFFECT_TYPE_LIFEBURST)
  lb:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
  end)
  lb:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  lb:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      Duel.Draw(tp,1)
    else
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    end
  end)
  -- [の間] 【常】 이미 LB를 가진 카드도 하나 더 얻는다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT_LIFEBURST)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(1,0)
  e1:SetTarget(function(e,x) return x:IsClass(0,RACE_SUIJU) end)
  e1:SetValue(1)
  e1:SetLabelObject(lb)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetCoinCost(1)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetLifetopGroup(1-tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local tc=Duel.SelectCards(tp,g,1,1):GetFirst()
    if not tc then return end
    Duel.SendToCheck(tc,tp)
    Duel.FireLifeBurst(tc,tp)
    Duel.SendToTrash(tc,REASON_EFFECT)
    local top=Duel.GetDecktopGroup(1-tp,1)
    if top:GetCount()>0 then Duel.SendToLife(top) end
  end)
  c:RegisterEffect(e2)
end
