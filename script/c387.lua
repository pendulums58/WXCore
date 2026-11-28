-- PR-K065A Ｓｔｉｒｒｅｄ　Ｈｅｒｏｉｎｅｓ（ウィクロスマガジン2019 Autumn 付録）
-- 【出】：あなたのデッキの上からカードを３枚公開する。その中から１枚を手札に加え、１枚をエナゾーンに置き、残りをトラッシュに置く。
-- 【起】このキーを場からルリグトラッシュに置き、トラッシュからレベルの合計が６以下になるように共通する色とクラスを持つシグニ２枚をゲームから除外する：あなたのルリグトラッシュから《レゾネーター》をレゾナとして場に出す。それが場を離れる場合、代わりにルリグトラッシュに置かれる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local h=Duel.SelectCards(tp,g,1,1)
    Duel.SendToHand(h)
    local r=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if r:GetCount()>0 then Duel.SendToEna(Duel.SelectCards(tp,r,1,1)) end
    r=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if r:GetCount()>0 then Duel.SendToTrash(r,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_TRASH,0,nil)
    local ok=function(sg)
      if sg:GetCount()~=2 then return false end
      local a,b=sg:GetFirst(),nil
      for x in sg:Iter() do if x~=a then b=x end end
      if a:GetLevel()+b:GetLevel()>6 or a:GetColor()&b:GetColor()==0 then return false end
      for _,ca in ipairs(a:GetClasses()) do for _,cb in ipairs(b:GetClasses()) do if ca==cb then return true end end end
      return false
    end
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) and g:GetCount()>=2 end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
    Duel.SetSelectCheck(ok)
    local sg=Duel.SelectCards(tp,g,2,2)
    s.excluded=s.excluded or {}
    s.excluded[tp]={}
    for x in sg:Iter() do table.insert(s.excluded[tp],x:GetCode()) end
    Duel.Exclude(sg)
  end)
  -- 제외한 시그니의 기본 레벨·파워(큰 값), 색·클래스·능력을 레조네이터가 얻는다(한정 조건은 낼 때만 보므로 생략)
  e2:SetOperation(function(e,tp)
    local r=Duel.GetMatchingGroup(function(x) return x:IsCardName(388) end,tp,LOCATION_LTRASH,0,nil):GetFirst()
    if not r then return end
    Duel.PutOnField(r,tp)
    if not r:IsLocation(LOCATION_SZONE) then return end
    local h=e:GetHandler()
    local function add(code,v)
      local e1=Effect.CreateEffect(h)
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(code)
      if v then e1:SetValue(v) end
      r:RegisterEffect(e1)
    end
    add(EFFECT_LEAVE_TO_LTRASH)
    local lv,pw=0,0
    for _,cid in ipairs(s.excluded and s.excluded[tp] or {}) do
      local x=Duel.GetMatchingGroup(function(c) return c:GetCode()==cid end,tp,LOCATION_EXCLUDE,0,nil):GetFirst()
      if x then
        lv=math.max(lv,x:GetLevel())
        pw=math.max(pw,x:GetPower())
        add(EFFECT_ADD_COLOR,x:GetColor())
        for _,cl in ipairs(x:GetClasses()) do add(EFFECT_ADD_CLASS,cl) end
        Duel.GainAbilities(r,cid)
      end
    end
    add(EFFECT_CHANGE_LEVEL,lv)
    add(EFFECT_SET_BASE_POWER,pw)
  end)
  c:RegisterEffect(e2)
end
