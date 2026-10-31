package dev.math.zzzopt.core.build;

import dev.math.zzzopt.core.equipment.DiscSet;
import dev.math.zzzopt.core.stats.Stat;
import dev.math.zzzopt.core.stats.StatBonus;
import dev.math.zzzopt.core.stats.Stats;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

/** Monta a ficha sem estado compartilhado, efeitos de combate, tetos ou arredondamentos. */
public final class BuildCalculator {
    public Stats calculate(Agent agent, WEngine engine, EquipmentBuild build,
                           List<DiscSet> sets) {
        Objects.requireNonNull(agent, "agent");
        Objects.requireNonNull(engine, "engine");
        Objects.requireNonNull(build, "build");
        var catalog = new HashMap<String, DiscSet>();
        for (var set : sets) {
            if (catalog.putIfAbsent(set.id(), set) != null) {
                throw new IllegalArgumentException("ID de conjunto repetido no catálogo: " + set.id());
            }
        }

        var bonuses = new ArrayList<>(engine.advancedStats());
        var pieces = new HashMap<String, Integer>();
        for (var disc : build.items()) {
            if (!catalog.containsKey(disc.set())) {
                throw new IllegalArgumentException("Conjunto desconhecido no disco "
                        + disc.id() + ": " + disc.set());
            }
            pieces.merge(disc.set(), 1, Integer::sum);
            bonuses.add(disc.main());
            bonuses.addAll(disc.substats());
        }
        pieces.forEach((id, count) -> {
            for (var effect : catalog.get(id).effects()) {
                if (effect.context() == DiscSet.Context.SHEET && count >= effect.requiredPieces()) {
                    bonuses.addAll(effect.bonuses());
                }
            }
        });

        var flat = new EnumMap<Stat, BigDecimal>(Stat.class);
        var percent = new EnumMap<Stat, BigDecimal>(Stat.class);
        for (var bonus : bonuses) {
            var target = bonus.type().multipliesBase() ? percent : flat;
            target.merge(bonus.type().stat(), bonus.value(), BigDecimal::add);
        }

        var result = new EnumMap<Stat, BigDecimal>(Stat.class);
        for (var stat : Stat.values()) {
            var base = agent.baseStats().value(stat);
            if (stat == Stat.ATTACK) {
                base = base.add(engine.baseAttack());
            }
            var multiplier = BigDecimal.ONE.add(percent.getOrDefault(stat, BigDecimal.ZERO).movePointLeft(2));
            result.put(stat, base.multiply(multiplier).add(flat.getOrDefault(stat, BigDecimal.ZERO)));
        }
        return new Stats(result);
    }
}
