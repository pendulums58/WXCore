-- WX22-021 幻水姫　ウラタロ
-- 【自】：各アタックフェイズ開始時、対戦相手の手札が５枚以上ある場合、対戦相手は手札を１枚捨てる。
-- 【出】《無》：シグニのカード名１つを宣言する。あなたのデッキの上から宣言したカードがめくれるまで公開し、それを手札に加える。残りをシャッフルしてデッキの一番下に置く。この方法でカードが７枚以上公開された場合、手札を１枚捨てる。
-- ライフバースト：カードを３枚引く。あなたは手札から無色のカードを１枚捨てないかぎりカードを２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetCondition(function(e,tp) return true end)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()>=5 then aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{C}")
  e2:SetOperation(function(e,tp)
    local cid=Duel.AnnounceCard(tp)
    local hit,seen=nil,Group.CreateGroup()
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,n do
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
      if last:IsCardName(cid) then hit=last break end
    end
    if seen:GetCount()==0 then return end
    Duel.RevealCards(seen)
    if hit then Duel.SendToHand(hit) end
    local rest=seen:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
    if seen:GetCount()>=7 then aux.Discard(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,3)
    local g=Duel.GetMatchingGroup(function(x) return x:GetColor()==0 end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp) then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) else aux.Discard(tp,2) end
  end)
  c:RegisterEffect(e3)
end
