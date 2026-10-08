package dev.math.zzzopt.core.damage;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DamageCalculatorTest {

    @ParameterizedTest
    @CsvSource({
            // multiplicador, bônus de dano total, dano do vídeo
            "11.631, 1.33, 1469126",   // 2:24 hold2
            "15.556, 1.33, 1964899",   // 2:22 hold3
            "15.556, 1.15, 1813104",   // 2:19 hold3 (sem o buff de 18%)
            "6.843,  1.15,  801279"    // 2:16 hold1 (sem o buff de 18%)
    })
    void holdComTresStacks(double mult, double dmgTotal, double esperado) {
        DamageInput in = new DamageInput();
        in.setAttackerLevel(60);
        in.setSkillMultiplier(mult);
        in.setAttack(2858 + 840 + 3475 * 0.3 + 50 + 2858 * 0.12);
        in.setCritDamage((208.4 + 30 + 32) / 100.0);
        in.setPenRatio(0.32);
        in.setPenFlat(27);
        in.setStunTotal(2.6);
        in.setDamageTotal(dmgTotal);
        in.setResPen(0.20);
        in.setTargetBaseDef(952);
        in.setAttributeRes(-0.20);

        double resultado = new DamageCalculator().calculate(in);

        assertEquals(esperado, resultado, esperado * 0.02); // tolerância de 2%
    }
}