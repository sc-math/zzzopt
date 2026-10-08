import dev.math.zzzopt.core.damage.DamageCalculator;
import dev.math.zzzopt.core.damage.DamageInput;

import java.util.List;

public class main {

    record Hit(String t, double mult, double video, boolean buff18) {}

    static DamageInput baseInput() {
        DamageInput v = new DamageInput();
        v.setAttackerLevel(60);
        v.setCritDamage((208.4 + 30 + 32) / 100.0);
        v.setPenRatio(0.32);
        v.setPenFlat(27);
        v.setStunTotal((200 + 30 + 30) / 100.0);
        v.setResPen(0.20);
        v.setTargetBaseDef(952);
        v.setAttributeRes(-0.20);
        return v;
    }

    public static void main(String[] args) {
        DamageCalculator calc = new DamageCalculator();

        List<Hit> holds = List.of(
                new Hit("2:26", 6.843,   898_296, true),
                new Hit("2:24", 11.631, 1_469_126, true),
                new Hit("2:22", 15.556, 1_964_899, true),
                new Hit("2:19", 15.556, 1_813_104, false),
                new Hit("2:16", 6.843,   801_279, false));

        for (Hit h : holds) {
            for (int s = 0; s <= 4; s++) {
                DamageInput in = baseInput();
                in.setSkillMultiplier(h.mult());
                in.setAttack(2858 + 840 + 3475 * 0.3 + 50 + 2858 * 0.04 * s);
                in.setDamageTotal((15 + 20 + 20 + 40 + 20 + (h.buff18() ? 18 : 0)) / 100.0);

                double r = calc.calculate(in);
                System.out.printf("%s stacks=%d erro=%.2f%%%n", h.t(), s, (r / h.video() - 1) * 100);
            }
            System.out.println();
        }
    }
}