-- WXK07-005 黒鍵の巫女　タマヨリヒメ
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード２：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。あなたのライフクロスが０枚の場合、代わりにターン終了時まで、それのパワーを－12000する。
-- 【常】：あなたのすべての領域にあるルリグとシグニは黒になる。
-- 【常】：あなたがエナコストを支払う際、あなたのエナゾーンから黒のカード１枚をトラッシュに置くことで好きな色のエナ１つを支払える。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(2)
    g:SetTiming(TIMING_ATTACK)
    g:SetCountLimit(1)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    end)
    g:SetOperation(function(e,tp)
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()==0 and -12000 or -7000) end
    end)
    local e91=Effect.CreateEffect(c)
    e91:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e91:SetDescription(aux.Ability(id,0))
    e91:SetCode(EFFECT_GRANT)
    e91:SetRange(LOCATION_KEY)
    e91:SetTargetRange(LOCATION_LRIG,0)
    e91:SetLabelObject(g)
    c:RegisterEffect(e91)
  end
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 루리그 덱의 그로우 코스트는 그대로(FAQ)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_CHANGE_COLOR)
  e2:SetRange(LOCATION_KEY)
  e2:SetTargetRange(LOCATION_SZONE+LOCATION_LRIG+LOCATION_HAND+LOCATION_MDECK+LOCATION_ENA+LOCATION_TRASH+LOCATION_LDECK+LOCATION_LTRASH+LOCATION_LIFE,0)
  e2:SetTarget(function(e,x) return x:IsSigni() or x:IsType(TYPE_LRIG) end)
  e2:SetValue(COLOR_BLACK)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EFFECT_ADD_PAY_COLOR)
  e3:SetRange(LOCATION_KEY)
  e3:SetTargetRange(LOCATION_ENA,0)
  e3:SetTarget(function(e,x) return x:IsColor(COLOR_BLACK) end)
  e3:SetValue(COLOR_WHITE|COLOR_RED|COLOR_BLUE|COLOR_GREEN|COLOR_BLACK)
  c:RegisterEffect(e3)
end
