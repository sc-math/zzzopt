package dev.math.zzzopt.core.equipment;

import java.util.HashSet;
import java.util.List;

/** IDs são únicos apenas no inventário recebido, não globalmente entre usuários. */
public record Inventory(List<Disc> items) {
    public Inventory {
        items = List.copyOf(items);
        var ids = new HashSet<String>();
        for (var disc : items) {
            if (!ids.add(disc.id())) {
                throw new IllegalArgumentException("ID de disco repetido no inventário: " + disc.id());
            }
        }
    }
}
