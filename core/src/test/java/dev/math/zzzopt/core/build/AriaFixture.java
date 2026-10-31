package dev.math.zzzopt.core.build;

import dev.math.zzzopt.core.equipment.Disc;
import dev.math.zzzopt.core.equipment.DiscRank;
import dev.math.zzzopt.core.equipment.DiscSet;
import dev.math.zzzopt.core.stats.Stat;
import dev.math.zzzopt.core.stats.StatBonus;
import dev.math.zzzopt.core.stats.Stats;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static dev.math.zzzopt.core.equipment.DiscSet.Context.COMBAT;
import static dev.math.zzzopt.core.equipment.DiscSet.Context.SHEET;
import static dev.math.zzzopt.core.stats.StatBonus.Type.*;
import static java.util.Map.entry;

/** Dados fornecidos pelo usuário. Não inclui previsão de aprimoramentos. */
final class AriaFixture {
    static Agent agent() {
        return new Agent("aria", "Aria", new Stats(Map.ofEntries(
                entry(Stat.HEALTH, new BigDecimal("7749")),
                entry(Stat.ATTACK, new BigDecimal("863")), // 788 + 3 x 25 da passiva; PV sem bônus da passiva.
                entry(Stat.DEFENSE, new BigDecimal("619")),
                entry(Stat.IMPACT, new BigDecimal("87")),
                entry(Stat.CRIT_RATE, new BigDecimal("5")),
                entry(Stat.CRIT_DAMAGE, new BigDecimal("50")),
                entry(Stat.ANOMALY_MASTERY, new BigDecimal("151")),
                entry(Stat.ANOMALY_PROFICIENCY, new BigDecimal("116")),
                entry(Stat.ENERGY_REGEN, new BigDecimal("1.2"))
        )));
    }

    static WEngine engine() {
        return new WEngine("anjo-na-concha", "Anjo na Concha", new BigDecimal("713"),
                List.of(b(ANOMALY_MASTERY_PERCENT, "30")));
    }

    static List<DiscSet> sets() {
        return List.of(
                new DiscSet("melodia-de-phaethon", "Melodia de Phaethon", List.of(
                        new DiscSet.Effect(2, SHEET, List.of(b(ANOMALY_MASTERY_PERCENT, "8")),
                                "Maestria de Anomalia +8%."),
                        new DiscSet.Effect(4, COMBAT, List.of(b(ANOMALY_PROFICIENCY_FLAT, "45")),
                                "Proficiência de Anomalia +45 em combate."),
                        new DiscSet.Effect(4, COMBAT, List.of(b(ETHER_DAMAGE_BONUS, "25")),
                                "Dano de Éter +25% em combate.")
                )),
                new DiscSet("destino-emplumado", "Destino Emplumado", List.of(
                        new DiscSet.Effect(2, SHEET, List.of(b(ANOMALY_PROFICIENCY_FLAT, "30")),
                                "Proficiência de Anomalia +30."),
                        new DiscSet.Effect(4, COMBAT, List.of(b(ANOMALY_PROFICIENCY_FLAT, "50")),
                                "Proficiência de Anomalia +50 em combate."),
                        new DiscSet.Effect(4, COMBAT, List.of(),
                                "Se for do elemento Lúmen, dano de anomalia +15% em combate.")
                ))
        );
    }

    static EquipmentBuild build() {
        return new EquipmentBuild(List.of(
                disc(1, "melodia-de-phaethon", b(HEALTH_FLAT, "2200"),
                        b(ANOMALY_PROFICIENCY_FLAT, "36"), b(PENETRATION_FLAT, "18"),
                        b(DEFENSE_FLAT, "15"), b(ATTACK_PERCENT, "3")),
                disc(2, "destino-emplumado", b(ATTACK_FLAT, "316"),
                        b(HEALTH_PERCENT, "3"), b(DEFENSE_PERCENT, "4.8"),
                        b(ANOMALY_PROFICIENCY_FLAT, "36"), b(ATTACK_PERCENT, "6")),
                disc(3, "melodia-de-phaethon", b(DEFENSE_FLAT, "184"),
                        b(ATTACK_FLAT, "38"), b(ATTACK_PERCENT, "6"),
                        b(ANOMALY_PROFICIENCY_FLAT, "27"), b(PENETRATION_FLAT, "9")),
                disc(4, "melodia-de-phaethon", b(ANOMALY_PROFICIENCY_FLAT, "92"),
                        b(CRIT_DAMAGE, "9.6"), b(CRIT_RATE, "4.8"),
                        b(ATTACK_PERCENT, "12"), b(DEFENSE_PERCENT, "4.8")),
                disc(5, "melodia-de-phaethon", b(ETHER_DAMAGE_BONUS, "30"),
                        b(ATTACK_PERCENT, "6"), b(ANOMALY_PROFICIENCY_FLAT, "27"),
                        b(ATTACK_FLAT, "38"), b(DEFENSE_PERCENT, "4.8")),
                disc(6, "destino-emplumado", b(ANOMALY_MASTERY_PERCENT, "30"),
                        b(PENETRATION_FLAT, "9"), b(ANOMALY_PROFICIENCY_FLAT, "36"),
                        b(CRIT_DAMAGE, "4.8"), b(ATTACK_PERCENT, "6"))
        ));
    }

    private static Disc disc(int gear, String set, StatBonus main, StatBonus... substats) {
        return new Disc("aria-disc-" + gear, gear, set, DiscRank.S, 15, main, List.of(substats));
    }

    private static StatBonus b(StatBonus.Type type, String value) {
        return StatBonus.of(type, value);
    }
}
