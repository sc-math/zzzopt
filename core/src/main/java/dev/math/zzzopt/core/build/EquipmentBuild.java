package dev.math.zzzopt.core.build;

import dev.math.zzzopt.core.equipment.Disc;
import dev.math.zzzopt.core.equipment.Inventory;

import java.util.Comparator;
import java.util.HashSet;
import java.util.List;

public record EquipmentBuild(List<Disc> items) {
    public EquipmentBuild {
        items = new Inventory(items).items();
        if (items.size() != 6) {
            throw new IllegalArgumentException("Uma build precisa de seis discos.");
        }
        var slots = new HashSet<Integer>();
        for (var disc : items) {
            if (!slots.add(disc.gear())) {
                throw new IllegalArgumentException("Slot repetido na build: " + disc.gear());
            }
        }
        items = items.stream().sorted(Comparator.comparingInt(Disc::gear)).toList();
    }
}
