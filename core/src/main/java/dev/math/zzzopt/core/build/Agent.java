package dev.math.zzzopt.core.build;

import dev.math.zzzopt.core.stats.Stats;

import java.util.Objects;

/** Base já inclui os acréscimos permanentes da passiva maximizada, uma única vez. */
public record Agent(String id, String name, Stats baseStats) {
    public Agent {
        if (id == null || id.isBlank() || name == null || name.isBlank()) {
            throw new IllegalArgumentException("O agente precisa de ID e nome.");
        }
        Objects.requireNonNull(baseStats, "baseStats");
    }
}
