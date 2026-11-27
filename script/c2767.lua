-- WX15-037 彩英の秘宝　#ノーベル#
-- 【常】：このシグニのパワーはあなたの場にある他の＜英知＞のシグニ１体につき＋3000される。
-- 【常】：このシグニは、このシグニの正面以外の対戦相手のシグニゾーンにもアタックできる。（シグニゾーンにアタックした場合、対戦相手にダメージを与えない）
-- ライフバースト：あなたのデッキの一番上を公開する。それが＜英知＞のシグニの場合、カードを２枚引く。そうでない場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 3000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,e:GetHandler()):GetCount() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_ATTACK_ZONE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetValue(0)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    Duel.Draw(tp,(function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) and 2 or 1)
  end)
  c:RegisterEffect(e3)
end
