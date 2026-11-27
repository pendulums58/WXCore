-- WX16-Re17 狂乱する博奕
-- あなたの手札を１枚選ぶ。対戦相手は《白2》《赤2》《青2》《緑2》《黒2》《無2》から１つと、シグニかスペルから１つを宣言する。その後、そのカードを公開する。そのカードが宣言されたアイコンとカードの種類のどちらも持たない場合、対戦相手のすべてのシグニをトラッシュに置く。どちらかを持つ場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。どちらも持つ場合、あなたは手札をすべて捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 then return end
    local x=Duel.SelectCards(tp,h,1,1):GetFirst()
    -- 상대 선언: 색 아이콘 1개(×2), 종류(예 = 시그니, 아니오 = 스펠)
    local cols={COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK,0}
    local ci=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4),aux.Stringid(id,5))+1
    local signi=Duel.SelectYesNo(1-tp)
    Duel.RevealCards(Group.CreateGroup(x))
    local col=cols[ci]
    local hit_icon=col~=0 and x:IsColor(col) or (col==0 and x:GetColor()==0)  -- 「《色2》」 아이콘을 색으로 근사
    local hit_type=signi and x:IsSigni() or (not signi and x:IsType(TYPE_SPELL))
    if not hit_icon and not hit_type then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    elseif hit_icon and hit_type then
      local all=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      if all:GetCount()>0 then Duel.SendToTrash(all,REASON_EFFECT+REASON_DISCARD) end
    else
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
