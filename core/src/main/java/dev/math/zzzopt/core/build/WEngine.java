package dev.math.zzzopt.core.build;

import dev.math.zzzopt.core.stats.StatBonus;

import java.math.BigDecimal;
import java.util.List;
import java.util.Objects;

/** Atributos do motor na condição escolhida para o catálogo; passivas de combate ficam fora. */
public record WEngine(String id, String name, BigDecimal baseAttack,
                      List<StatBonus> advancedStats) {
    public WEngine {
        if (id == null || id.isBlank() || name == null || name.isBlank()) {
            throw new IllegalArgumentException("O motor precisa de ID e nome.");
        }
        Objects.requireNonNull(baseAttack, "baseAttack");
        if (baseAttack.signum() < 0) {
            throw new IllegalArgumentException("O ATQ básico do motor não pode ser negativo.");
        }
        advancedStats = List.copyOf(advancedStats);
    }
}
