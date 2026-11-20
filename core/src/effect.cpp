#include "effect.h"

namespace wx {

EffectId EffectTable::create() {
  Effect e;
  e.id = static_cast<EffectId>(list_.size() + 1);
  list_.push_back(std::move(e));
  return list_.back().id;
}

}  // namespace wx
