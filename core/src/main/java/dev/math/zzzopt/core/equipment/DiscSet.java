package dev.math.zzzopt.core.equipment;

import dev.math.zzzopt.core.stats.StatBonus;

import java.util.List;
import java.util.Objects;

public record DiscSet(String id, String name, List<Effect> effects) {
    public DiscSet {
        if (id == null || id.isBlank() || name == null || name.isBlank()) {
            throw new IllegalArgumentException("O conjunto precisa de ID e nome.");
        }
        effects = List.copyOf(effects);
    }

    public enum Context {
        SHEET, COMBAT
    }

    /** Vários efeitos podem ter o mesmo requisito de peças e contextos distintos. */
    public record Effect(int requiredPieces, Context context, List<StatBonus> bonuses,
                         String description) {
        public Effect {
            if (requiredPieces != 2 && requiredPieces != 4) {
                throw new IllegalArgumentException("O efeito deve exigir duas ou quatro peças.");
            }
            Objects.requireNonNull(context, "context");
            bonuses = List.copyOf(bonuses);
            if (description == null || description.isBlank()) {
                throw new IllegalArgumentException("O efeito precisa de uma descrição.");
            }
            if (context == Context.SHEET && bonuses.isEmpty()) {
                throw new IllegalArgumentException("Um efeito de ficha precisa de bônus estruturados.");
            }
        }
    }
}
