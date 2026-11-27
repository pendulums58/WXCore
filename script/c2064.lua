-- WX04-096 堕落の破戒　オリエンス
-- 【常】：このシグニに【チャーム】が付いているかぎり、このシグニの基本パワーは12000になる。
-- 【起】《ダウン》：あなたの＜悪魔＞のシグニ１体を対象とし、あなたのデッキの一番上のカードをそれの【チャーム】にしてもよい。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return e:GetHandler():GetCharm()~=nil end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  -- 【チャーム】는 뒷면으로, 붙인 쪽도 못 본다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local tc,top=Duel.GetFirstTarget(),Duel.GetDecktopGroup(tp,1):GetFirst()
    if tc and tc:IsRelateToEffect(e) and top and not tc:GetCharm() and Duel.SelectYesNo(tp) then Duel.Charm(top,tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
