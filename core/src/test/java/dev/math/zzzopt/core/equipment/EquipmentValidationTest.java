package dev.math.zzzopt.core.equipment;

import dev.math.zzzopt.core.build.EquipmentBuild;
import dev.math.zzzopt.core.stats.Stat;
import dev.math.zzzopt.core.stats.StatBonus;
import dev.math.zzzopt.core.stats.Stats;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static dev.math.zzzopt.core.stats.StatBonus.Type.*;
import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Validação dos equipamentos e proteção dos dados de entrada")
class EquipmentValidationTest {
    @Test
    @DisplayName("Deve aceitar peças idênticas com IDs diferentes e preservar o aprimoramento atual")
    void acceptsIdenticalPiecesWithDifferentIdsAndCurrentEnhancementValues() {
        var first = disc("one", 1);
        var second = disc("two", 1);

        var inventory = new Inventory(List.of(first, second));

        assertEquals(2, inventory.items().size());
        assertEquals(first.main(), second.main());
        assertEquals(0, first.enhance());
    }

    @Test
    @DisplayName("Deve rejeitar IDs de discos repetidos no inventário")
    void rejectsRepeatedInventoryIds() {
        assertThrows(IllegalArgumentException.class,
                () -> new Inventory(List.of(disc("same", 1), disc("same", 2))));
    }

    @Test
    @DisplayName("Deve impedir que alterações nas listas originais modifiquem o inventário e os discos")
    void inventoryAndDiscDefensivelyCopyTheirLists() {
        var substats = new ArrayList<>(List.of(StatBonus.of(ATTACK_PERCENT, "3")));
        var first = new Disc("one", 1, "set", DiscRank.S, 0, StatBonus.of(HEALTH_FLAT, "100"), substats);
        var items = new ArrayList<>(List.of(first));
        var inventory = new Inventory(items);

        substats.clear();
        items.clear();

        assertEquals(1, inventory.items().size());
        assertEquals(1, first.substats().size());
        assertThrows(UnsupportedOperationException.class, () -> inventory.items().clear());
        assertThrows(UnsupportedOperationException.class, () -> first.substats().clear());
    }

    @Test
    @DisplayName("Deve impedir que alterações no mapa original modifiquem os atributos da ficha")
    void statsDefensivelyCopyTheirMap() {
        var values = new HashMap<Stat, BigDecimal>();
        values.put(Stat.ATTACK, new BigDecimal("863"));
        var stats = new Stats(values);

        values.put(Stat.ATTACK, BigDecimal.ZERO);

        assertEquals(new BigDecimal("863"), stats.value(Stat.ATTACK));
        assertThrows(UnsupportedOperationException.class, () -> stats.values().clear());
    }

    @DisplayName("Deve rejeitar slots fora do intervalo de 1 a 6")
    @ParameterizedTest(name = "Slot inválido: {0}")
    @ValueSource(ints = {0, 7})
    void rejectsInvalidSlots(int gear) {
        assertThrows(IllegalArgumentException.class, () -> disc("invalid", gear));
    }

    @DisplayName("Deve rejeitar aprimoramentos fora do intervalo inicial de 0 a 15")
    @ParameterizedTest(name = "Aprimoramento inválido: {0}")
    @ValueSource(ints = {-1, 16})
    void rejectsEnhancementOutsideTheInitialSupportedRange(int enhance) {
        assertThrows(IllegalArgumentException.class, () -> new Disc("invalid", 1, "set", DiscRank.S,
                enhance, StatBonus.of(HEALTH_FLAT, "100"), List.of()));
    }

    @Test
    @DisplayName("Deve rejeitar discos sem conjunto ou com atributo principal incompatível com o slot fixo")
    void rejectsMissingSetAndIncompatibleFixedMainStat() {
        assertThrows(IllegalArgumentException.class, () -> new Disc("invalid", 1, " ", DiscRank.S,
                0, StatBonus.of(HEALTH_FLAT, "100"), List.of()));
        assertThrows(IllegalArgumentException.class, () -> new Disc("invalid", 1, "set", DiscRank.S,
                0, StatBonus.of(ATTACK_FLAT, "100"), List.of()));
    }

    @Test
    @DisplayName("Deve exigir seis peças com IDs distintos e uma peça em cada slot")
    void requiresSixDistinctSlotsAndSixDistinctPieces() {
        assertThrows(IllegalArgumentException.class, () -> new EquipmentBuild(List.of(disc("one", 1))));
        assertThrows(IllegalArgumentException.class, () -> new EquipmentBuild(List.of(
                disc("one", 1), disc("two", 2), disc("three", 3), disc("four", 4),
                disc("five", 5), disc("six", 5))));
        assertThrows(IllegalArgumentException.class, () -> new EquipmentBuild(List.of(
                disc("same", 1), disc("same", 2), disc("three", 3), disc("four", 4),
                disc("five", 5), disc("six", 6))));
    }

    private static Disc disc(String id, int gear) {
        var main = switch (gear) {
            case 1 -> HEALTH_FLAT;
            case 2 -> ATTACK_FLAT;
            case 3 -> DEFENSE_FLAT;
            default -> ANOMALY_PROFICIENCY_FLAT;
        };
        return new Disc(id, gear, "set", DiscRank.S, 0, StatBonus.of(main, "100"), List.of());
    }
}
