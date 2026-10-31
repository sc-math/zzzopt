package dev.math.zzzopt.core.equipment;

import dev.math.zzzopt.core.stats.StatBonus;

import java.util.HashSet;
import java.util.List;
import java.util.Objects;

/** Peça física: atributos iguais não tornam duas peças com IDs diferentes iguais. */
public record Disc(String id, int gear, String set, DiscRank rank, int enhance,
                   StatBonus main, List<StatBonus> substats) {
    public Disc {
        if (id == null || id.isBlank()) {
            throw new IllegalArgumentException("O disco precisa de um ID.");
        }
        if (gear < 1 || gear > 6) {
            throw new IllegalArgumentException("O slot deve estar entre 1 e 6: " + id);
        }
        if (set == null || set.isBlank()) {
            throw new IllegalArgumentException("O disco precisa de um conjunto: " + id);
        }
        Objects.requireNonNull(rank, "rank");
        if (enhance < 0 || enhance > 15) {
            throw new IllegalArgumentException("O aprimoramento deve estar entre 0 e 15: " + id);
        }
        Objects.requireNonNull(main, "main");
        substats = List.copyOf(substats);
        if (substats.size() > 4) {
            throw new IllegalArgumentException("O disco pode ter até quatro subatributos: " + id);
        }
        var types = new HashSet<StatBonus.Type>();
        for (var bonus : substats) {
            if (!types.add(bonus.type())) {
                throw new IllegalArgumentException("Subatributo repetido no disco: " + id);
            }
            if (bonus.type() == main.type()) {
                throw new IllegalArgumentException("O atributo principal não pode se repetir nos subatributos: " + id);
            }
        }
        var fixedMain = switch (gear) {
            case 1 -> StatBonus.Type.HEALTH_FLAT;
            case 2 -> StatBonus.Type.ATTACK_FLAT;
            case 3 -> StatBonus.Type.DEFENSE_FLAT;
            default -> null;
        };
        if (fixedMain != null && main.type() != fixedMain) {
            throw new IllegalArgumentException("Atributo principal incompatível com o slot: " + id);
        }
    }
}
