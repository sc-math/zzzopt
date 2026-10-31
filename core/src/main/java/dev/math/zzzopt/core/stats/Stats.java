package dev.math.zzzopt.core.stats;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.EnumMap;
import java.util.Map;
import java.util.Objects;

/** Ficha imutável, sem arredondamento de exibição e sem tetos de gameplay. */
public record Stats(Map<Stat, BigDecimal> values) {
    public Stats {
        Objects.requireNonNull(values, "values");
        var copy = new EnumMap<Stat, BigDecimal>(Stat.class);
        values.forEach((stat, value) -> {
            Objects.requireNonNull(stat, "stat");
            Objects.requireNonNull(value, "value");
            if (value.signum() < 0) {
                throw new IllegalArgumentException("O atributo não pode ser negativo: " + stat);
            }
            copy.put(stat, value);
        });
        values = Collections.unmodifiableMap(copy);
    }

    public BigDecimal value(Stat stat) {
        return values.getOrDefault(Objects.requireNonNull(stat, "stat"), BigDecimal.ZERO);
    }
}
