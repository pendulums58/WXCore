-- PR-K022 新鋭の巫女　タマヨリヒメ（コロコロアニキ2018年夏号 付録）
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》エクシード２：数字１つを宣言する。その後、あなたのデッキの上からカードを３枚公開する。その中に宣言した数字と同じレベルのシグニがある場合、対戦相手のシグニ１体を対象とし、それを手札に戻す。この効果で公開したカードを好きな順番でデッキの一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_IGNITION)
  g:SetDescription(aux.Ability(id,1))
  g:SetRange(LOCATION_LRIG)
  g:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  g:SetCountLimit(1)
  g:SetExceedCost(2)
  g:SetOperation(function(e,tp)
    local lv=Duel.AnnounceNumber(tp,0,5)
    local d=Duel.GetDecktopGroup(tp,3)
    if d:GetCount()==0 then return end
    Duel.RevealCards(d)
    if d:Filter(function(x) return x:IsSigni() and x:GetLevel()==lv end,nil):GetCount()>0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.SendToHand(tc) end
    end
    local rest=d:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
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
