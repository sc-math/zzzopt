package dev.math.zzzopt.core.build;

import dev.math.zzzopt.core.equipment.Disc;
import dev.math.zzzopt.core.equipment.DiscRank;
import dev.math.zzzopt.core.equipment.DiscSet;
import dev.math.zzzopt.core.stats.Stat;
import dev.math.zzzopt.core.stats.StatBonus;
import dev.math.zzzopt.core.stats.Stats;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static dev.math.zzzopt.core.equipment.DiscSet.Context.COMBAT;
import static dev.math.zzzopt.core.equipment.DiscSet.Context.SHEET;
import static dev.math.zzzopt.core.stats.StatBonus.Type.*;
import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Montagem dos atributos da ficha")
class BuildCalculatorTest {
    private final BuildCalculator calculator = new BuildCalculator();

    @DisplayName("Deve montar a ficha da Aria sem bônus de combate ou arredondamento de exibição")
    @ParameterizedTest(name = "{0}: deve resultar em {1}")
    @CsvSource({
            "HEALTH, 10181.47", // Fórmula decimal; o jogo mostra 10182. Arredondamento ainda não definido.
            "ATTACK, 2582.64",
            "DEFENSE, 907.136",
            "IMPACT, 87",
            "CRIT_RATE, 9.8",
            "CRIT_DAMAGE, 64.4",
            "ANOMALY_MASTERY, 253.68",
            "ANOMALY_PROFICIENCY, 400",
            "PENETRATION_FLAT, 36",
            "PENETRATION_RATE, 0",
            "ENERGY_REGEN, 1.2",
            "ETHER_DAMAGE_BONUS, 30",
            "PHYSICAL_DAMAGE_BONUS, 0"
    })
    void assemblesAriaSheetWithoutCombatBonusesOrDisplayRounding(Stat stat, String expected) {
        var result = calculator.calculate(AriaFixture.agent(), AriaFixture.engine(),
                AriaFixture.build(), AriaFixture.sets());

        assertValue(result, stat, expected);
    }

    @Test
    @DisplayName("Não deve somar peças de conjuntos diferentes para ativar efeitos iguais")
    void identicalEffectsFromDifferentSetsDoNotSharePieceCounts() {
        var sets = List.of(set("a", 100), set("b", 100), set("c", 100),
                set("d", 100), set("e", 100), set("f", 100));

        var result = calculateZeroBase(build("a", "b", "c", "d", "e", "f"), sets);

        assertValue(result, Stat.ANOMALY_PROFICIENCY, "0");
    }

    @Test
    @DisplayName("Deve ativar os três bônus independentes de uma composição 2+2+2")
    void activatesThreeIndependentTwoPieceBonuses() {
        var result = calculateZeroBase(build("a", "a", "b", "b", "c", "c"),
                List.of(set("a", 10), set("b", 20), set("c", 30)));

        assertValue(result, Stat.ANOMALY_PROFICIENCY, "60");
    }

    @Test
    @DisplayName("Deve aplicar os bônus de ficha de duas e quatro peças uma única vez e ignorar a parte de combate")
    void activatesTwoAndFourPieceSheetEffectsOnceAndIgnoresCombatPart() {
        var mixed = new DiscSet("a", "A", List.of(
                new DiscSet.Effect(2, SHEET, List.of(StatBonus.of(CRIT_RATE, "5")), "Duas peças."),
                new DiscSet.Effect(4, SHEET, List.of(StatBonus.of(CRIT_RATE, "7")), "Parte fixa de quatro peças."),
                new DiscSet.Effect(4, COMBAT, List.of(StatBonus.of(CRIT_RATE, "100")), "Parte condicional.")
        ));

        var result = calculateZeroBase(build("a", "a", "a", "a", "a", "a"), List.of(mixed));

        assertValue(result, Stat.CRIT_RATE, "12");
    }

    @Test
    @DisplayName("Não deve impor um teto automático de taxa crítica")
    void doesNotImposeACriticalRateCap() {
        var agent = new Agent("test", "Test", new Stats(Map.of(Stat.CRIT_RATE, new BigDecimal("195"))));
        var engine = new WEngine("test", "Test", BigDecimal.ZERO, List.of(StatBonus.of(CRIT_RATE, "20")));

        var result = calculator.calculate(agent, engine, build("a", "a", "a", "a", "a", "a"),
                List.of(new DiscSet("a", "A", List.of())));

        assertValue(result, Stat.CRIT_RATE, "215");
    }

    @Test
    @DisplayName("Deve rejeitar conjuntos desconhecidos e identificar o disco afetado")
    void rejectsUnknownSetsWithTheAffectedDiscId() {
        var error = assertThrows(IllegalArgumentException.class,
                () -> calculateZeroBase(build("missing", "a", "a", "a", "a", "a"), List.of(set("a", 10))));

        assertTrue(error.getMessage().contains("disc-1"));
        assertTrue(error.getMessage().contains("missing"));
    }

    @Test
    @DisplayName("Deve rejeitar IDs de conjuntos repetidos no catálogo")
    void rejectsDuplicateCatalogIdsInsteadOfSelectingOneSilently() {
        assertThrows(IllegalArgumentException.class, () -> calculateZeroBase(
                build("a", "a", "a", "a", "a", "a"), List.of(set("a", 10), set("a", 20))));
    }

    @Test
    @DisplayName("Deve repetir o cálculo sem acumular bônus ou alterar os dados de entrada")
    void repeatedCalculationsDoNotAccumulateBonusesOrChangeInputs() {
        var agent = AriaFixture.agent();
        var engine = AriaFixture.engine();
        var equipment = AriaFixture.build();
        var sets = AriaFixture.sets();

        var first = calculator.calculate(agent, engine, equipment, sets);
        var second = calculator.calculate(agent, engine, equipment, sets);

        assertEquals(first, second);
        assertValue(agent.baseStats(), Stat.ATTACK, "863");
        assertEquals(1, engine.advancedStats().size());
        assertEquals(4, equipment.items().getFirst().substats().size());
    }

    private Stats calculateZeroBase(EquipmentBuild build, List<DiscSet> sets) {
        return calculator.calculate(new Agent("test", "Test", new Stats(Map.of())),
                new WEngine("test", "Test", BigDecimal.ZERO, List.of()), build, sets);
    }

    private static DiscSet set(String id, int proficiency) {
        return new DiscSet(id, id, List.of(new DiscSet.Effect(2, SHEET,
                List.of(StatBonus.of(ANOMALY_PROFICIENCY_FLAT, Integer.toString(proficiency))), "Duas peças.")));
    }

    private static EquipmentBuild build(String... setIds) {
        var discs = new ArrayList<Disc>();
        for (int index = 0; index < setIds.length; index++) {
            var main = switch (index + 1) {
                case 1 -> HEALTH_FLAT;
                case 2 -> ATTACK_FLAT;
                case 3 -> DEFENSE_FLAT;
                case 4 -> ANOMALY_PROFICIENCY_FLAT;
                case 5 -> ETHER_DAMAGE_BONUS;
                case 6 -> ANOMALY_MASTERY_PERCENT;
                default -> throw new IllegalArgumentException("Slot inválido no cenário de teste.");
            };
            discs.add(new Disc("disc-" + (index + 1), index + 1, setIds[index], DiscRank.S,
                    0, StatBonus.of(main, "0"), List.of()));
        }
        return new EquipmentBuild(discs);
    }

    private static void assertValue(Stats stats, Stat stat, String expected) {
        assertEquals(0, new BigDecimal(expected).compareTo(stats.value(stat)),
                () -> stat + ": esperado " + expected + ", recebido " + stats.value(stat));
    }
}
