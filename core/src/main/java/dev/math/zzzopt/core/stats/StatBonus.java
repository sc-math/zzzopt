package dev.math.zzzopt.core.stats;

import java.math.BigDecimal;
import java.util.Objects;

/** Valor final do bônus, sem histórico de rolls. Percentuais usam 55 para 55%. */
public record StatBonus(Type type, BigDecimal value) {
    public StatBonus {
        Objects.requireNonNull(type, "type");
        Objects.requireNonNull(value, "value");
        if (value.signum() < 0) {
            throw new IllegalArgumentException("O bônus não pode ser negativo.");
        }
    }

    public static StatBonus of(Type type, String value) {
        return new StatBonus(type, new BigDecimal(value));
    }

    public enum Type {
        HEALTH_FLAT(Stat.HEALTH, false),
        HEALTH_PERCENT(Stat.HEALTH, true),
        ATTACK_FLAT(Stat.ATTACK, false),
        ATTACK_PERCENT(Stat.ATTACK, true),
        DEFENSE_FLAT(Stat.DEFENSE, false),
        DEFENSE_PERCENT(Stat.DEFENSE, true),
        IMPACT_FLAT(Stat.IMPACT, false),
        IMPACT_PERCENT(Stat.IMPACT, true),
        CRIT_RATE(Stat.CRIT_RATE, false),
        CRIT_DAMAGE(Stat.CRIT_DAMAGE, false),
        ANOMALY_MASTERY_FLAT(Stat.ANOMALY_MASTERY, false),
        ANOMALY_MASTERY_PERCENT(Stat.ANOMALY_MASTERY, true),
        ANOMALY_PROFICIENCY_FLAT(Stat.ANOMALY_PROFICIENCY, false),
        ANOMALY_PROFICIENCY_PERCENT(Stat.ANOMALY_PROFICIENCY, true),
        PENETRATION_FLAT(Stat.PENETRATION_FLAT, false),
        PENETRATION_RATE(Stat.PENETRATION_RATE, false),
        ENERGY_REGEN_FLAT(Stat.ENERGY_REGEN, false),
        ENERGY_REGEN_PERCENT(Stat.ENERGY_REGEN, true),
        PHYSICAL_DAMAGE_BONUS(Stat.PHYSICAL_DAMAGE_BONUS, false),
        FIRE_DAMAGE_BONUS(Stat.FIRE_DAMAGE_BONUS, false),
        ICE_DAMAGE_BONUS(Stat.ICE_DAMAGE_BONUS, false),
        ELECTRIC_DAMAGE_BONUS(Stat.ELECTRIC_DAMAGE_BONUS, false),
        ETHER_DAMAGE_BONUS(Stat.ETHER_DAMAGE_BONUS, false);

        private final Stat stat;
        private final boolean multipliesBase;

        Type(Stat stat, boolean multipliesBase) {
            this.stat = stat;
            this.multipliesBase = multipliesBase;
        }

        public Stat stat() {
            return stat;
        }

        public boolean multipliesBase() {
            return multipliesBase;
        }
    }
}
